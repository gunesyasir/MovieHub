//
//  MoviesViewModel.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation
import RealmSwift

class PopularMoviesViewModel {
    private var currentPageCount = 0
    private(set) var movieDetailData: Movie?
    private(set) var movieList: [Movie] = []
    private var notificationToken: NotificationToken? = nil
    private var totalPageCount = 0
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func fetchMovies(completion: @escaping (String?) -> Void) {
        let service: PopularMoviesServiceProtocol = PopularMoviesService()
        service.getPopularMovies(pageAt: currentPageCount + 1) { [weak self] result in
            guard let self = self else {
                completion(LocalizedStrings.errorMessage.localized)
                return
            }
            
            switch result {
                case .success(let data):
                    self.movieList.append(contentsOf: data.results)
                    self.currentPageCount = data.page ?? self.currentPageCount + 1
                    self.totalPageCount = data.totalPages ?? self.totalPageCount
                    completion(nil)
                            
                case .failure( _):
                    completion(LocalizedStrings.errorMessage.localized)
            }
        }
    }
    
    func fetchMoreMoviesIfNeeded(currentIndex: Int, completion: @escaping (String?) -> Void) {
        guard currentIndex == movieList.count - 1, currentPageCount < totalPageCount else { return }
        
        fetchMovies(completion: completion)
    }
    
    func fetchMovieDetail(of id: Int, completion: @escaping (String?) -> Void) {
        NetworkUtils.getMovieDetail(of: id) { [weak self] result in
            guard let self = self else {
                completion(LocalizedStrings.errorMessage.localized)
                return
            }
            
            switch result {
                case .success(let data):
                    self.movieDetailData = data
                    completion(nil)
                    
                case .failure( _):
                    self.movieDetailData = nil
                    completion(LocalizedStrings.errorMessage.localized)
            }
        }
    }
    
    func observeChanges(completion: @escaping (Result<RealmCollectionChangeStatus, DBManagerError>) -> Void) {
        if let dbManager = DBManager<Movie>.shared {
            dbManager.observeChanges(notificationToken: &self.notificationToken) { result in
                switch result {
                case .success(let status):
                    completion(.success(status))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(.initializationFailed))
        }
    }
}
