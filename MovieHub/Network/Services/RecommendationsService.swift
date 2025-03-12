//
//  RecommendationsService.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

protocol RecommendationsServiceProtocol {
    func getRecommendedMovies(of id: Int, pageAt pageNo: Int, completion: @escaping (Result<MovieListResponse, Error>) -> Void)
}

final class RecommendationsService: RecommendationsServiceProtocol {
    func getRecommendedMovies(of id: Int, pageAt pageNo: Int, completion: @escaping (Result<MovieListResponse, any Error>) -> Void) {
        NetworkManager.shared.sendRequest(to: .movieRecommendations(movieId: id), add: [URLQueryItem(name: PAGE, value: String(pageNo))], completionHandler: completion)
    }
}
