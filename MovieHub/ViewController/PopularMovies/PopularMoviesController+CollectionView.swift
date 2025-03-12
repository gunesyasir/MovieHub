//
//  MovieController+CollectionView.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

extension PopularMoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource, MovieCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularMoviesViewModel.movieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MovieCollectionViewCell.self), for: indexPath) as! MovieCollectionViewCell
        
        let movie = popularMoviesViewModel.movieList[indexPath.row]
        
        configureCell(cell, for: movie)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = popularMoviesViewModel.movieList[indexPath.row]
        
        fetchMovieDetail(of: movie.id)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        popularMoviesViewModel.fetchMoreMoviesIfNeeded(currentIndex: indexPath.row) { [weak self] error in
            // No need to show error message because there is already data on screen.
            if error != nil { return }
            self?.collectionView.reloadData()
        }
    }
    
    func configureCell(_ cell: MovieCollectionViewCell, for movie: Movie) {
        cell.delegate = self
        
        if let manager = movieDBManager {
            manager.isObjectInDatabase(primaryKey: movie.id) { result in
                switch result {
                    case .failure( _):
                        break
                    case .success(let isBookmarked):
                        cell.isBookmarked = isBookmarked
                }
            }
        }
        
        cell.setShadowAndBorder(radius: 8, borderWidth: 0.5, borderColor: UIColor.clear.cgColor, shadowColor: UIColor.systemGray.cgColor, shadowRadius: 1, bounds: cell.bounds)
        
        let posterURL = ImageUtils.getImageURL(from: movie.posterPath)
        cell.moviePoster.setImage(with: posterURL)
        cell.rating.text = "⭐️ " + (movie.voteAverage ?? 1.0).toOneDecimalPoint()
        cell.name.text = movie.title
        cell.releaseDate.text = DateUtils.convertToMonthAndYearFormat(from: movie.releaseDate)
    }
    
    func didTapBookmarkButton(_ cell: MovieCollectionViewCell) {
        updatePersistentData(for: cell)
    }
    
    private func updatePersistentData(for cell: MovieCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let movieId = popularMoviesViewModel.movieList[indexPath.row].id
            
            if let manager = movieDBManager {
                manager.fetchObjectByPrimaryKey(primaryKey: movieId){ result in
                    switch result {
                        case .failure( _):
                            break
                        case .success(let movie):
                            if let movie = movie {
                                manager.deleteObject(primaryKey: movie.id) { result in
                                    switch result {
                                        case .failure( _):
                                            break
                                        case .success( _):
                                            cell.isBookmarked = !cell.isBookmarked
                                    }
                                }
                            } else {
                                manager.saveObject(self.popularMoviesViewModel.movieList[indexPath.row]) { result in
                                    switch result {
                                        case .failure( _):
                                            break
                                        case .success( _):
                                            cell.isBookmarked = !cell.isBookmarked
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
}

extension PopularMoviesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.frame.width
        let cellTextContentHeight: CGFloat = 85
        let imageAspectRatio = 1.35
        
        let cellWidth = collectionViewWidth / 3 - 4
        let cellHeight = cellWidth * imageAspectRatio + cellTextContentHeight
        
        return CGSize(width: cellWidth , height: cellHeight)
        
    }
}
