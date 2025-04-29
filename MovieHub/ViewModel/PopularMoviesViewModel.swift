//
//  MoviesViewModel.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation
import RealmSwift
import Combine

enum MovieDetailResult {
    case success(Movie)
    case failure(message: String, id: Int)
}

class PopularMoviesViewModel {
    @Published private(set) var movieList: [Movie] = []
    @Published private(set) var movieDetailResult: MovieDetailResult?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var bookmarkedMovies: [Int] = []
    @Published private(set) var bookmarkStatusChangedMovieId: Int?
    private var cancellables = Set<AnyCancellable>()
    
    private var notificationToken: NotificationToken?
    private var currentPageCount = 0
    private var totalPageCount = 0
    
    private let movieService: PopularMoviesServiceProtocol
    private let dbManager: MovieDBManager
        
    init(movieService: PopularMoviesServiceProtocol = PopularMoviesService(), dbManager: MovieDBManager = .shared) {
        self.movieService = movieService
        self.dbManager = dbManager
        
        fetchInitialData()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func fetchMovies() {
        isLoading = true
        movieService.getPopularMovies(pageAt: currentPageCount + 1) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let data):
                self.movieList.append(contentsOf: data.results)
                self.currentPageCount = data.page ?? self.currentPageCount + 1
                self.totalPageCount = data.totalPages ?? self.totalPageCount
            case .failure:
                self.errorMessage = LocalizedStrings.errorMessage.localized
            }
        }
    }
    
    func fetchMoreMoviesIfNeeded(currentIndex: Int) {
        guard currentIndex == movieList.count - 1, currentPageCount < totalPageCount else { return }
        
        fetchMovies()
    }
    
    func fetchMovieDetail(of id: Int) {
        isLoading = true
        NetworkUtils.getMovieDetail(of: id) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let data):
                self.movieDetailResult = .success(data)
            case .failure:
                self.movieDetailResult = .failure(message: LocalizedStrings.errorMessage.localized, id: id)
            }
        }
    }

    private func observeChanges() {
        MovieDBManager.shared.observeCollectionNew(notificationToken: &notificationToken)
            .sink { [weak self] value in
                guard let self = self else { return }
                
                switch value {
                case .initial(_): break
                case .update(let newCollection, let deletions, let insertions, _):
                    if !deletions.isEmpty {
                        let id = self.bookmarkedMovies[deletions.first!]
                        self.bookmarkStatusChangedMovieId = id
                        
                        self.bookmarkedMovies.remove(at: deletions.first!)
                    }
                    
                    if !insertions.isEmpty {
                        let id = newCollection[insertions.first!].id
                        self.bookmarkedMovies.append(id)
                        self.bookmarkStatusChangedMovieId = id
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchBookmarkedCollection() {
        let objects = dbManager.fetchAllObjectsNew()
        let ids = objects.map { $0.id }
        bookmarkedMovies = ids
    }
    
    private func fetchInitialData() {
        fetchBookmarkedCollection()
        observeChanges()
        fetchMovies()
    }
    
    func isBookmarked(for id: Int) -> Bool {
        return bookmarkedMovies.contains(id)
    }
    
    func toggleBookmark(for movie: Movie) {
        dbManager.fetchObjectByPrimaryKey(primaryKey: movie.id) { [weak self] result in
            switch result {
            case .success(let object):
                if let _ = object {
                    self?.dbManager.deleteObject(primaryKey: movie.id) { _ in }
                } else {
                    self?.dbManager.saveObject(movie) { _ in }
                }
            case .failure:
                break
            }
        }
    }
}
