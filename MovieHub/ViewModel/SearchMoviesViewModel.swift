//
//  SearchMoviesViewModel.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

class SearchMoviesViewModel {
    var errorMessage = ""
    var movieDetailData: Movie?
    var movieList: [Movie] = []
    var previousQueryText: String = "" // Flag to compare new request should send due to text change or new page.
    var currentPageCount = 0
    var totalPageCount = 0
    
    func fetchData(for queryText: String, completion: @escaping () -> Void) {
        errorMessage = ""
        
        let sentDueToPagination = previousQueryText == queryText
        self.previousQueryText = queryText
        
        if !sentDueToPagination {
            currentPageCount = 0
            totalPageCount = 0
        }
        
        let service: SearchMoviesServiceProtocol = SearchMoviesService()
        service.searchMovies(for: queryText, pageAt: currentPageCount + 1) { result in
            
            switch result {
            case .success(let data):
                if (sentDueToPagination) {
                    self.movieList.append(contentsOf: data.results)
                } else {
                    self.movieList = data.results
                }
                
                self.currentPageCount = data.page ?? self.currentPageCount + 1
                self.totalPageCount = data.totalPages ?? self.totalPageCount
                completion()
                
            case .failure(_):
                self.errorMessage = LocalizedStrings.errorMessage.localized
                completion()
            }
        }
    }
    
    func fetchMovieDetail(of id: Int, completion: @escaping () -> Void) {
        errorMessage = ""
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
                self.errorMessage = LocalizedStrings.errorMessage.localized
                completion()
            }
        }
    }
}
