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
    
    private(set) var popularMoviesViewModel = PopularMoviesViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        setUpCollectionView()
        setupBindings()
    }
    
    private func setupBindings() {
        popularMoviesViewModel.$movieList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        popularMoviesViewModel.$movieDetailResult
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let movie):
                    NavigationUtils.navigateToMovieDetail(from: self, movie: movie)
                case .failure(let message, let id):
                    self.showError(message: message, onTryAgain: {
                        self.popularMoviesViewModel.fetchMovieDetail(of: id)
                    })
                }
            }
            .store(in: &cancellables)
        
        popularMoviesViewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showError(message: message, onTryAgain: {
                    self?.popularMoviesViewModel.fetchMovies()
                })
            }
            .store(in: &cancellables)
        
        popularMoviesViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.toggleActivityIndicator(show: isLoading)
            }
            .store(in: &cancellables)
        
        popularMoviesViewModel.$bookmarkStatusChangedMovieId
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] value in
                guard let strongSelf = self else { return }
                
                let list = strongSelf.popularMoviesViewModel.movieList
                let index = list.firstIndex(where: { $0.id == value })
                if let index = index {
                    let indexPath = IndexPath(item: index, section: 0)
                    strongSelf.collectionView?.reloadItems(at: [indexPath])
                }
            }.store(in: &cancellables)
    }
    
    func fetchMovieDetail(of id: Int) {
        popularMoviesViewModel.fetchMovieDetail(of: id)
    }
    
    private func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: String(describing: MovieCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MovieCollectionViewCell.self))
    }
}
