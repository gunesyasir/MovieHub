//
//  MovieCastServices.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

protocol MovieCastServiceProtocol {
    func fetchCast(of id: Int, completion: @escaping (Result<CastResponse, Error>) -> Void)
}

final class MovieCastService: MovieCastServiceProtocol {
    func fetchCast(of id: Int, completion: @escaping (Result<CastResponse, any Error>) -> Void) {
        NetworkManager.shared.sendRequest(to: .movieCast(movieId: id), completionHandler: completion)
    }
}
