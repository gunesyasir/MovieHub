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
    private let service: SearchMoviesServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    @Published var textPublisher: String = ""
    @Published private(set) var errorEvent: SearchRequestType?
    @Published private(set) var movieDetailData: Movie?
    @Published private(set) var movieList: [Movie] = []
    var movieListPublisher: AnyPublisher<[Movie], Never> {
        $movieList
            .dropFirst()
            .removeDuplicates(by: { $0.map(\.id) == $1.map(\.id) })
            .eraseToAnyPublisher()
    }
    private var currentPageCount = 0
    private var totalPageCount = 0
    
    init(service: SearchMoviesServiceProtocol = SearchMoviesService()) {
        self.service = service
        
        $textPublisher
            .dropFirst()
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.fetchData(false)
            }
            .store(in: &cancellables)
    }
    
    private func fetchData(_ sentDueToPagination: Bool) {
        errorEvent = nil
        
        if !sentDueToPagination {
            currentPageCount = 0
            totalPageCount = 0
        }
                        
        service.searchMovies(for: textPublisher, pageAt: currentPageCount + 1) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    if (sentDueToPagination) {
                        self.movieList.append(contentsOf: data.results)
                    } else {
                        self.movieList = data.results
                    }
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
    
    func loadMore(currentIndex: Int) {
        guard currentIndex == movieList.count - 1, currentPageCount < totalPageCount else { return }
        fetchData(true)
    }
    
    func search() {
        fetchData(false)
    }
}
