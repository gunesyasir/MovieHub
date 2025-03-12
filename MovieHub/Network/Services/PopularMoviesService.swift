//
//  MovieList.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

protocol PopularMoviesServiceProtocol {
    func getPopularMovies(pageAt pageNo: Int, completion: @escaping (Result<MovieListResponse, Error>) -> Void)
}

final class PopularMoviesService: PopularMoviesServiceProtocol {
    func getPopularMovies(pageAt pageNo: Int, completion: @escaping (Result<MovieListResponse, Error>) -> Void) {
        NetworkManager.shared.sendRequest(to: .popularMovies, add: [URLQueryItem(name: PAGE, value: String(pageNo))], completionHandler: completion)
    }
    
}
