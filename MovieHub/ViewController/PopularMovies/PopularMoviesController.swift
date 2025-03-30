//
//  MovieController.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit
import Kingfisher
import Combine

final class PopularMoviesViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barItem: UITabBarItem!
    
    var popularMoviesViewModel = PopularMoviesViewModel()
    let movieDBManager = MovieDBManager.shared
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        setUpCollectionView()
        fetchMovies()
        setupBindings()
    }
        
    private func setupBindings() {
        popularMoviesViewModel.movieDetailData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                self.toggleActivityIndicator(show: false)
                
                switch result {
                    case .success(let movie):
                        NavigationUtils.navigateToMovieDetail(from: self, movie: movie)
                    case .failure(let message, let id):
                        self.showError(message: message, onTryAgain: {
                            self.fetchMovieDetail(of: id)
                        })
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchMovieDetail(of id: Int) {
        toggleActivityIndicator(show: true)
        popularMoviesViewModel.fetchMovieDetail(of: id)
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
