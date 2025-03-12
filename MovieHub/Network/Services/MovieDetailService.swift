//
//  MovieDetailService.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

protocol MovieDetailServiceProtocol {
    func getMovieDetail(of id: Int, completion: @escaping (Result<Movie, Error>) -> Void)
}

final class MovieDetailService: MovieDetailServiceProtocol {
    func getMovieDetail(of id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        NetworkManager.shared.sendRequest(to: .movieDetail(movieId: id), completionHandler: completion)
    }
}
