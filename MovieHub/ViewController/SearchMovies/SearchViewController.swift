//
//  SearchViewController.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit
import Combine

final class SearchViewController: BaseViewController {
    @IBOutlet weak var barItem: UITabBarItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchMoviesViewModel = SearchMoviesViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = LocalizedStrings.searchByMovie.localized
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableViewCell.getNib(), forCellReuseIdentifier: String(describing: MovieTableViewCell.self))
        setupBindings()
        observeSearchBar()
    }
    
    private func setupBindings() {
        searchMoviesViewModel.$movieList
            .dropFirst()
            .removeDuplicates(by: { firstOutput, secondOutput in
                let idList1 = firstOutput.map { $0.id }
                let idList2 = secondOutput.map { $0.id }
                return idList1 == idList2
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        searchMoviesViewModel.$movieDetailData
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movie in
                guard let self = self else { return }
                NavigationUtils.navigateToMovieDetail(from: self, movie: movie)
            }
            .store(in: &cancellables)
        
        searchMoviesViewModel.$errorEvent
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                switch error {
                case .movieList(let message):
                    self.showError(message: message, onTryAgain: {
                        self.searchMoviesViewModel.fetchData(for: self.searchMoviesViewModel.previousQueryText)
                    })
                case .movieDetail(let id, let message):
                    self.showError(message: message, onTryAgain: {
                        self.fetchMovieDetail(of: id)
                    })
                }
            }
            .store(in: &cancellables)
    }
    
    private func observeSearchBar() {
        NotificationCenter.default
            .publisher(for: UISearchTextField.textDidChangeNotification, object: searchBar.searchTextField)
            .compactMap { ($0.object as? UISearchTextField)?.text }
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.searchMoviesViewModel.fetchData(for: text)
            }
            .store(in: &cancellables)
    }
    
    func fetchMovies(for queryString: String) {
        searchMoviesViewModel.fetchData(for: queryString)
    }
    
    func fetchMovieDetail(of id: Int) {
        searchMoviesViewModel.fetchMovieDetail(of: id)
    }
}
