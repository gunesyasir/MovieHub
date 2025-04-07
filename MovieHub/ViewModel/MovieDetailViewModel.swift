//
//  MovieDetailViewModel.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation
import RealmSwift
import Combine

class MovieDetailViewModel {
    @Published var movie: Movie
    @Published private(set) var actorDetailData: Cast?
    @Published private(set) var isCastRequestCompleted = false
    var errorMessage = ""
    private(set) var existInDatabase = CurrentValueSubject<Bool, Never>(false)
    @Published private(set) var recommendedMovieDetailData: (id: Int, movie: Movie?)?
    private var movieUpdatedInDatabase = false // DB is updated asynchronously so this flag needed to update just once.
    @Published private(set) var recommendedsCurrentPageCount = 0
    private(set) var recommendedsTotalPageCount = 0
    @Published private(set) var isRecommendedsRequestCompleted = false
    private var notificationToken: NotificationToken? = nil

    init(movie: Movie) {
        self.movie = movie
        startObservingMovie()
        fetchMovieCast()
        fetchRecommendations(at: nil)
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    private func addToPersistentStorage(completion: @escaping (Result<Void, DBManagerError>) -> Void) {
        DBManager.shared.saveObject(movie, completion: completion)
    }
    
    private func fetchMovieCast() {
        errorMessage = ""
        
        let service: MovieCastServiceProtocol = MovieCastService()
        service.fetchCast(of: movie.id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                let list = data.cast.filter { $0.role == ACTING }
                movie.cast.append(objectsIn: list)
                
            case .failure( _):
                self.errorMessage = LocalizedStrings.errorMessage.localized
            }
            
            self.isCastRequestCompleted = true
            self.updateDataIfMovieExistsInDatabase()
        }
    }
    
    func fetchActorDetail(of id: Int) {
        let service: CastDetailServiceProtocol = CastDetailService()
        service.getCastDetail(of: id) { result in
            switch result {
                case .success(let data):
                    self.actorDetailData = data
                    
                case .failure(_):
                    self.actorDetailData = nil
                    // TODO: Check if actor in db
            }
        }
    }
    
    func fetchMovieDetail(of id: Int) {
        NetworkUtils.getMovieDetail(of: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.recommendedMovieDetailData = (id: id, movie: data)
            case .failure( _):
                self.fetchMovieDetailFromDatabase(of: id)
            }
        }
    }
    
    func fetchRecommendations(at index: Int?) {
        guard index == nil || (index == movie.recommendedMovies.count - 1 && recommendedsCurrentPageCount < recommendedsTotalPageCount) else {
            return
        }

        errorMessage = ""
        
        let service: RecommendationsServiceProtocol = RecommendationsService()
        service.getRecommendedMovies(of: movie.id, pageAt: recommendedsCurrentPageCount + 1) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                let recommendedMovies = data.results.map { movie in
                    RecommendedMovie(from: movie)
                }
                movie.recommendedMovies.append(objectsIn: recommendedMovies)
                self.recommendedsCurrentPageCount = data.page ?? self.recommendedsCurrentPageCount + 1
                self.recommendedsTotalPageCount = data.totalPages ?? self.recommendedsTotalPageCount
                
            case .failure( _):
                self.errorMessage = LocalizedStrings.errorMessage.localized
            }
            
            self.isRecommendedsRequestCompleted = true
            self.updateDataIfMovieExistsInDatabase()
        }
    }
    
    func fetchMovieDetailFromDatabase(of id: Int) {
        let manager = DBManager.shared
        manager.isObjectInDatabase(primaryKey: id) { result in
            switch result {
            case .success(let isExists):
                if isExists {
                    manager.fetchObjectByPrimaryKey(primaryKey: id) { result in
                        switch result {
                        case .success(let data):
                            self.recommendedMovieDetailData = (id: id, movie: data)
                        case .failure( _):
                            self.errorMessage = LocalizedStrings.errorMessage.localized
                            self.recommendedMovieDetailData = (id: id, movie: nil)
                        }
                    }
                } else {
                    self.errorMessage = LocalizedStrings.errorMessage.localized
                    self.recommendedMovieDetailData = (id: id, movie: nil)
                }
            case .failure( _):
                self.errorMessage = LocalizedStrings.errorMessage.localized
                self.recommendedMovieDetailData = (id: id, movie: nil)
            }
        }
    }
    
    private func startObservingMovie() {
        DBManager.shared.observeObject(for: movie.id, objectNotificationToken: &self.notificationToken) { result in
            switch result {
            case .success(.exist):
                self.existInDatabase.send(true)
            case .success(.nonExist):
                self.existInDatabase.send(false)
            case .failure(_):
                break
            }
        }
    }
    
    func updateDatabase() {
        let completion: (Result<Void, DBManagerError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.existInDatabase.send(!self.existInDatabase.value)
            case .failure(_):
                break
            }
        }
        
        if existInDatabase.value {
            removeFromPersistentStorage(completion: completion)
        } else {
            addToPersistentStorage(completion: completion)
        }
    }
    
    func updateDataIfMovieExistsInDatabase() {
        if movieUpdatedInDatabase || !isRecommendedsRequestCompleted || !isCastRequestCompleted {
            return
        }
        
        movieUpdatedInDatabase = true
        
        DatabaseUtils.updateDataIfMovieExistsInDatabase(for: movie)
    }
    
    private func removeFromPersistentStorage(completion: @escaping (Result<Void, DBManagerError>) -> Void) {
        DBManager.shared.deleteObject(primaryKey: movie.id, completion: completion)
    }
}
