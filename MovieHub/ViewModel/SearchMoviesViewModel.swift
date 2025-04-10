//
//  SearchMoviesViewModel.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation
import Combine

enum SearchRequestType {
    case movieList(message: String)
    case movieDetail(id: Int, message: String)
}

class SearchMoviesViewModel {
    @Published private(set) var errorEvent: SearchRequestType?
    @Published private(set) var movieDetailData: Movie?
    @Published private(set) var movieList: [Movie] = []
    private(set) var currentPageCount = 0
    private(set) var totalPageCount = 0
    private(set) var previousQueryText: String = "" // Flag to compare new request should send due to text change or new page.
    
    func fetchData(for queryText: String) {
        errorEvent = nil
        
        let sentDueToPagination = previousQueryText == queryText
        self.previousQueryText = queryText
        
        if !sentDueToPagination {
            currentPageCount = 0
            totalPageCount = 0
        }
        
        let service: SearchMoviesServiceProtocol = SearchMoviesService()
        service.searchMovies(for: queryText, pageAt: currentPageCount + 1) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                if (sentDueToPagination) {
                    self.movieList.append(contentsOf: data.results)
                } else {
                    self.movieList = data.results
                }
                
                self.currentPageCount = data.page ?? self.currentPageCount + 1
                self.totalPageCount = data.totalPages ?? self.totalPageCount
                
            case .failure(_):
                self.errorEvent = .movieList(message: LocalizedStrings.errorMessage.localized)
            }
        }
    }
    
    func fetchMovieDetail(of id: Int) {
        errorEvent = nil
        
        NetworkUtils.getMovieDetail(of: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.movieDetailData = data
                
            case .failure( _):
                self.movieDetailData = nil
                self.errorEvent = .movieDetail(id: id, message: LocalizedStrings.errorMessage.localized)
            }
        }
    }
}
