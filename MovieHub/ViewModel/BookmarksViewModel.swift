//
//  BookmarksViewModel.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation
import RealmSwift

class BookmarksViewModel {
    private var dbManager = DBManager.shared
    private var errorMessage = ""
    var movieDetailData: Movie?
    private var notificationToken: NotificationToken? = nil
    var movieList: [Movie] {
        var fetchedResults: [Movie] = []
        
        dbManager.fetchAllObjects { result in
            switch result {
            case .success(let results):
                fetchedResults = results
            case .failure(_):
                break
            }
        }
        return fetchedResults
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func fetchMovieDetail(of id: Int, completion: @escaping () -> Void) {
        NetworkUtils.getMovieDetail(of: id) { [weak self] result in
            guard let self = self else {
                completion()
                return
            }
            
            switch result {
            case .success(let data):
                self.movieDetailData = data
                completion()
                
            case .failure( _):
                self.movieDetailData = nil
                self.fetchMovieDetailFromDatabase(of: id, completion: completion)
            }
        }
    }
    
    func fetchMovieDetailFromDatabase(of id: Int, completion: @escaping () -> Void) {
        dbManager.fetchObjectByPrimaryKey(primaryKey: id, completion: { result in
            switch result {
            case .success(let data):
                self.movieDetailData = data
                completion()
                
            case .failure( _):
                completion()
            }
        })
    }
    
    func observeChanges(completion: @escaping (Result<RealmCollectionChangeStatus, DBManagerError>) -> Void) {
        dbManager.observeCollection(notificationToken: &self.notificationToken) { result in
            switch result {
            case .success(let status):
                completion(.success(status))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func removeItem(at index: Int, completion: @escaping (Result<Void, MovieAppError>) -> Void) {
        let movie = movieList[index]
        
        errorMessage = ""
        
        dbManager.deleteObject(primaryKey: movie.id) { result in
            switch result {
            case .success:
                break
            case .failure:
                self.errorMessage = LocalizedStrings.errorMessage.localized
            }
        }
    }
}
