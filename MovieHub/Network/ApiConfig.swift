//
//  ApiConfig.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

struct ApiConfig {
    static let apiKey = "fe1d40ee1e22d8926690d9dc1f4c89cc"
    static let baseURL = "https://api.themoviedb.org/3/"
    static let baseImageURL = "https://image.tmdb.org/t/p/w500"
}

enum ApiEndpoint {
    case castDetail(castId: Int)
    case discoverMovies
    case movieCast(movieId: Int)
    case movieDetail(movieId: Int)
    case movieRecommendations(movieId: Int)
    case popularMovies
    case searchMovies
    
    var url: String {
        switch self {
            case .castDetail(let castId):
                return "person/\(castId)"
            case .discoverMovies:
                return "discover/movie"
            case .movieCast(let movieId):
                return "movie/\(movieId)/credits"
            case .movieDetail(let movieId):
                return "movie/\(movieId)"
            case .movieRecommendations(let movieId):
                return "movie/\(movieId)/recommendations"
            case .popularMovies:
                return "movie/popular"
            case .searchMovies:
                return "search/movie"
        }
    }
}


enum NetworkError: Error {
    case transportationError
    case requestFailed
    case dataConversionFailure
}
