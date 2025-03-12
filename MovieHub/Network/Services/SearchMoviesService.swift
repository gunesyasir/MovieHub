//
//  SearchMoviesService.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

protocol SearchMoviesServiceProtocol {
    func searchMovies(for queryString: String, pageAt pageNo: Int, completion: @escaping (Result<MovieListResponse, Error>) -> Void)
}

final class SearchMoviesService: SearchMoviesServiceProtocol {
    func searchMovies(for queryString: String, pageAt pageNo: Int, completion: @escaping (Result<MovieListResponse, Error>) -> Void) {
        NetworkManager.shared.sendRequest(to: .searchMovies, add: [
            URLQueryItem(name: QUERY, value: queryString),
            URLQueryItem(name: PAGE, value: String(pageNo))
        ], completionHandler: completion)
    }
    
}
