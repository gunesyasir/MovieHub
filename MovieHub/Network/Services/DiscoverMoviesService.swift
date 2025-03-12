//
//  DiscoverMoviesService.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

protocol DiscoverMoviesServiceProtocol {
    func discoverMovies(pageAt pageNo: Int, withGenreId genreId: Int?, completion: @escaping (Result<MovieListResponse, Error>) -> Void)
}

final class DiscoverMoviesService: DiscoverMoviesServiceProtocol {
    func discoverMovies(pageAt pageNo: Int, withGenreId genreId: Int?, completion: @escaping (Result<MovieListResponse, Error>) -> Void) {
        var queryParametersList: [URLQueryItem] = [URLQueryItem(name: PAGE, value: String(pageNo))]
        
        if let id = genreId {
            queryParametersList.append(URLQueryItem(name: WITH_GENRES, value: String(id)))
        }
        
        NetworkManager.shared.sendRequest(to: .discoverMovies, add: queryParametersList, completionHandler: completion)
    }
}
