//
//  MovieController.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit
import Kingfisher

final class PopularMoviesViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barItem: UITabBarItem!
    
    var popularMoviesViewModel = PopularMoviesViewModel()
    let movieDBManager = DBManager<Movie>.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        setUpCollectionView()
        fetchMovies()
    }
    
    func fetchMovieDetail(of id: Int) {
        toggleActivityIndicator(show: true)
        popularMoviesViewModel.fetchMovieDetail(of: id) { [weak self] error in
            self?.toggleActivityIndicator(show: false)
            
            if let movie = self?.popularMoviesViewModel.movieDetailData {
                NavigationUtils.navigateToMovieDetail(from: self!, movie: movie)
                return
            }
            
            if let error = error {
                self?.showError(message: error, onTryAgain: {
                    self?.fetchMovieDetail(of: id)
                })
            }
        }
    }
        
    private func fetchMovies() {
        toggleActivityIndicator(show: true)
        popularMoviesViewModel.fetchMovies { [weak self] error in
            self?.toggleActivityIndicator(show: false)
            
            if let error = error {
                self?.showError(message: error, onTryAgain: { self?.fetchMovies() })
            } else {
                self?.collectionView.reloadData()
            }
        }
        
        popularMoviesViewModel.observeChanges() { [weak self] (result: Result<RealmCollectionChangeStatus, DBManagerError>) in
            self?.toggleActivityIndicator(show: false)
            
            DispatchQueue.main.async {
                switch result {
                case .success(.initial):
                    break
                case .success(.update(_, _, _)):
                    self?.collectionView.reloadData()
                case .failure(_):
                    break
                }
            }
        }
    }

    private func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: String(describing: MovieCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MovieCollectionViewCell.self))
    }
    
}


