//
//  SearchViewController.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

final class SearchViewController: BaseViewController {
    @IBOutlet weak var barItem: UITabBarItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchMoviesViewModel = SearchMoviesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = LocalizedStrings.searchByMovie.localized
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableViewCell.getNib(), forCellReuseIdentifier: String(describing: MovieTableViewCell.self))
    }
    
    func fetchMovies(for queryString: String) {
        searchMoviesViewModel.fetchData(for: queryString) { [weak self] in
            if (self?.searchMoviesViewModel.errorMessage.isEmpty ?? true) {
                self?.tableView.reloadData()
            } else {
                self?.showAlertDialog(message: self?.searchMoviesViewModel.errorMessage ?? "", actions: [
                    UIAlertAction(title: LocalizedStrings.ok.localized, style: .default, handler: nil),
                    UIAlertAction(title: LocalizedStrings.tryAgain.localized, style: .default, handler: { _ in
                        self?.fetchMovies(for: queryString)
                    })
                ])
            }
        }
    }
    
    func fetchMovieDetail(of id: Int) {
        searchMoviesViewModel.fetchMovieDetail(of: id) { [weak self] in
            if let movie = self?.searchMoviesViewModel.movieDetailData {
                NavigationUtils.navigateToMovieDetail(from: self!, movie: movie)
            } else {
                self?.showError(message: self!.searchMoviesViewModel.errorMessage, onTryAgain: {
                    self?.fetchMovieDetail(of: id)
                })
            }
        }
    }

}
