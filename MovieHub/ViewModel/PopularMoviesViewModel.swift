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
    private var currentPageCount = 0
    private(set) var movieDetailData = PassthroughSubject<MovieDetailResult, Never>()
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
    
    func fetchMovieDetail(of id: Int) {
        NetworkUtils.getMovieDetail(of: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.movieDetailData.send(.success(data))
                
            case .failure( _):
                self.movieDetailData.send(.failure(message: LocalizedStrings.errorMessage.localized,id: id))
            }
        }
    }
    
    func observeChanges(completion: @escaping (Result<RealmCollectionChangeStatus, DBManagerError>) -> Void) {
        MovieDBManager.shared.observeCollection(notificationToken: &self.notificationToken) { result in
            switch result {
            case .success(let status):
                completion(.success(status))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
