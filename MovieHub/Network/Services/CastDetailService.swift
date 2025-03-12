//
//  CastDetailService.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

protocol CastDetailServiceProtocol {
    func getCastDetail(of id: Int, completion: @escaping (Result<Cast, Error>) -> Void)
}

final class CastDetailService: CastDetailServiceProtocol {
    func getCastDetail(of id: Int, completion: @escaping (Result<Cast, any Error>) -> Void) {
        NetworkManager.shared.sendRequest(to: .castDetail(castId: id), completionHandler: completion)
    }
}
