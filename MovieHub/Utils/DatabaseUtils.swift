//
//  DatabaseUtils.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

struct DatabaseUtils {
    static func updateDataIfMovieExistsInDatabase(for movie: Movie) {
        let manager = MovieDBManager.shared
        manager.isObjectInDatabase(primaryKey: movie.id) { result in
            switch result {
            case .success(let isExists):
                if isExists {
                    manager.saveObject(movie) { _ in
                        debugPrint("Persisted data updated.")
                    }
                }
            case .failure( _):
                break
            }
        }
    }
}


