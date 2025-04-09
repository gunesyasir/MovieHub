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
    var tableViewData: [[String: Any]] {
        var data: [[String: Any]] = []
        if let title = movie.originalTitle, !title.isEmpty {
            data.append([LocalizedStrings.originalTitle.localized : title])
        }
        if let budget = movie.budget, budget != 0 {
            data.append([LocalizedStrings.budget.localized : budget])
        }
        if let revenue = movie.revenue, revenue != 0 {
            data.append([LocalizedStrings.revenue.localized : revenue])
        }
        let companies = Array(movie.productionCompanies)
        if companies.count > 0, let name = companies[0].name {
            data.append([LocalizedStrings.productionCompany.localized: name])
        }
        
        return data
    }
    var title: String? {
        movie.title
    }
    var backdropUrl: URL? {
        ImageUtils.getImageURL(from: movie.backdropPath)
    }
    var posterUrl: URL? {
        ImageUtils.getImageURL(from: movie.posterPath)
    }
    var movieInfoLine: String? {
        var parts: [String] = []
        
        if let runtime = movie.runtime {
            parts.append("🕓 \(runtime)")
        }

        if let rate = movie.voteAverage {
            parts.append("⭐️ \(rate.toOneDecimalPoint())")
        }

        if let langCode = movie.spokenLanguages.first?.code,
           let language = LanguageUtils.getLocalizedLanguageName(fromCode: langCode) {
            parts.append("🔊 \(language)")
        }
        
        return parts.isEmpty ? nil : parts.joined(separator: "  ")
    }
    var releaseDate: String? {
        DateUtils.convertToMonthAndYearFormat(from: movie.releaseDate)
    }
    var overview: String? {
        movie.overview
    }
    var castLabel: String {
        LocalizedStrings.cast.localized
    }
    var recommendationsLabel: String {
        LocalizedStrings.recommendations.localized
    }
    var shouldShowGenres: Bool {
        !movie.genres.isEmpty
    }
    var shouldShowHomepageButton: Bool {
        guard let page = movie.homepage else { return false }
        return URL(string: page) != nil
    }
    var homepageUrl: URL {
        return URL(string: movie.homepage!)! // Non-optional because shouldShowHomepageButton assures it
    }
    var castList: [CastViewModel] = []
    var recommendedMovieList: [RecommendedMovieViewModel] = []

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
        MovieDBManager.shared.saveObject(movie, completion: completion)
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
                self.castList = list.map { CastViewModel(cast: $0) }
                
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
                let movies = recommendedMovies.map { RecommendedMovieViewModel(movie: $0) }
                self.recommendedMovieList.append(contentsOf: movies)
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
        let manager = MovieDBManager.shared
        manager.isObjectInDatabase(primaryKey: id) { result in
            switch result {
            case .success(let isExists):
                if isExists {
                    manager.fetchObjectByPrimaryKey(primaryKey: id, fetchType: .detached) { result in
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
        MovieDBManager.shared.observeObject(for: movie.id, objectNotificationToken: &self.notificationToken) { result in
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
        MovieDBManager.shared.deleteObject(primaryKey: movie.id, completion: completion)
    }
    
    func genreName(at index: Int) -> String {
        return movie.genres[index].name ?? ""
    }
    
    func castItem(at index: Int) -> CastViewModel? {
        guard index < castList.count else { return nil }
        return castList[index]
    }
    
    func recommendedMovieItem(at index: Int) -> RecommendedMovieViewModel? {
        guard index < recommendedMovieList.count else { return nil }
        return recommendedMovieList[index]
    }
}
