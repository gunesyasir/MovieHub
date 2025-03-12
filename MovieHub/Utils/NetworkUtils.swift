//
//  NetworkUtils.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

struct NetworkUtils {
     static func getMovieDetail(of id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
         let service: MovieDetailServiceProtocol = MovieDetailService()
        service.getMovieDetail(of: id) { result in
            switch result {
                case .success(let data):
                    completion(.success(data))
                    
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
