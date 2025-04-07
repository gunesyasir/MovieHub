//
//  MovieDetailVİewModel.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation
import RealmSwift

class MovieDetailViewModel {
    let movie: Movie
    var actorDetailData: Cast?
    var castRequestCompleted = false
    var errorMessage = ""
    var existInDatabase = false
    var movieDetailData: Movie?
    var movieUpdatedInDatabase = false // DB is updated asynchronously so this flag needed to update just once.
    var recommendedsCurrentPageCount = 0
    var recommendedsTotalPageCount = 0
    var recommendedsRequestCompleted = false
    private var notificationToken: NotificationToken? = nil

    init(movie: Movie) {
        self.movie = movie
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func addToPersistentStorage(completion: @escaping (Result<Void, DBManagerError>) -> Void) {
        MovieDBManager.shared.saveObject(movie, completion: completion)
    }
    
    func fetchMovieCast(completion: @escaping () -> Void) {
        errorMessage = ""
        
        let service: MovieCastServiceProtocol = MovieCastService()
        service.fetchCast(of: movie.id) { [weak self] result in
            guard let self = self else {
                completion()
                return
            }
            
            switch result {
            case .success(let data):
                let list = data.cast.filter { $0.role == ACTING }
                movie.cast.append(objectsIn: list)
                completion()
                
            case .failure( _):
                self.errorMessage = LocalizedStrings.errorMessage.localized
                completion()
            }
        }
    }
    
    func fetchCastDetail(of id: Int, completion: @escaping () -> Void) {
        let service: CastDetailServiceProtocol = CastDetailService()
        service.getCastDetail(of: id) { result in
            switch result {
                case .success(let data):
                    self.actorDetailData = data
                    completion()
                    
                case .failure(_):
                    self.actorDetailData = nil
                    // TODO: Check if actor in db
                    completion()
            }
        }
    }
    
    func fetchMovieDetail(of id: Int, completion: @escaping () -> Void) {
        NetworkUtils.getMovieDetail(of: id) { [weak self] result in
            guard let self = self else {
                completion()
                return
            }
            
            switch result {
                case .success(let data):
                    self.movieDetailData = data
                    completion()
                    
                case .failure( _):
                    self.movieDetailData = nil
                    self.fetchMovieDetailFromDatabase(of: id, completion: completion)
            }
        }
    }
    
    func fetchRecommendations(completion: @escaping () -> Void) {
        errorMessage = ""
        
        let service: RecommendationsServiceProtocol = RecommendationsService()
        service.getRecommendedMovies(of: movie.id, pageAt: recommendedsCurrentPageCount + 1) { [weak self] result in
            guard let self = self else {
                completion()
                return
            }
            
            switch result {
                case .success(let data):
                    let recommendedMovies = data.results.map { movie in
                        RecommendedMovie(from: movie)
                    }
                    movie.recommendedMovies.append(objectsIn: recommendedMovies)
                    self.recommendedsCurrentPageCount = data.page ?? self.recommendedsCurrentPageCount + 1
                    self.recommendedsTotalPageCount = data.totalPages ?? self.recommendedsTotalPageCount
                    completion()
                    
                case .failure( _):
                    self.errorMessage = LocalizedStrings.errorMessage.localized
                    completion()
                }
        }
    }
    
    func fetchMovieDetailFromDatabase(of id: Int, completion: @escaping () -> Void) {
        let manager = MovieDBManager.shared
            manager.isObjectInDatabase(primaryKey: id) { result in
                switch result {
                    case .success(let isExists):
                        if isExists {
                            manager.fetchObjectByPrimaryKey(primaryKey: id) { result in
                                switch result {
                                    case .success(let data):
                                        self.movieDetailData = data
                                        completion()
                                    case .failure( _):
                                        self.errorMessage = LocalizedStrings.errorMessage.localized
                                        completion()
                                }
                            }
                        } else {
                            self.errorMessage = LocalizedStrings.errorMessage.localized
                            completion()
                        }
                    case .failure( _):
                        self.errorMessage = LocalizedStrings.errorMessage.localized
                        completion()
                }
            }
    }
    

    
    func fetchPersistentStorageStatus(completion: @escaping () -> Void) {
        let manager = MovieDBManager.shared
            manager.isObjectInDatabase(primaryKey: movie.id) { [weak self] result in
                switch result {
                    case .success(let isExists):
                        self?.existInDatabase = isExists
                        completion()
                    case .failure( _):
                        self?.existInDatabase = false
                        completion()
                }
            }
    }
    
    func observeObject(completion: @escaping (Result<Void, DBManagerError>) -> Void) {
        let dbManager = MovieDBManager.shared
            dbManager.observeObject(for: movie.id, objectNotificationToken: &self.notificationToken) { result in
                switch result {
                    case .success(.change):
                        self.existInDatabase = true
                        completion(.success(()))
                    case .success(.delete):
                        self.existInDatabase = false
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
     
    }
    
    func updateDataIfMovieExistsInDatabase() {
        if movieUpdatedInDatabase || !recommendedsRequestCompleted || !castRequestCompleted {
            return
        }
        
        movieUpdatedInDatabase = true
        
        DatabaseUtils.updateDataIfMovieExistsInDatabase(for: movie)
    }
    
    func removeFromPersistentStorage(completion: @escaping (Result<Void, DBManagerError>) -> Void) {
        MovieDBManager.shared.deleteObject(primaryKey: movie.id, completion: completion)
    }
}
