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
        popularMoviesViewModel.fetchMoreMoviesIfNeeded(currentIndex: indexPath.row)
    }
    
    func configureCell(_ cell: MovieCollectionViewCell, for movie: Movie) {
        cell.delegate = self
        
        let isBookmarked = popularMoviesViewModel.isBookmarked(for: movie.id)
        cell.isBookmarked = isBookmarked
        
        cell.setShadowAndBorder(radius: 8, borderWidth: 0.5, borderColor: UIColor.clear.cgColor, shadowColor: UIColor.systemGray.cgColor, shadowRadius: 1, bounds: cell.bounds)
        
        let posterURL = ImageUtils.getImageURL(from: movie.posterPath)
        cell.moviePoster.setImage(with: posterURL)
        let rating = movie.voteAverage ?? 0.0
        cell.rating.text = rating == 0.0 ? "⭐️ N/A" : "⭐️ \(rating.toOneDecimalPoint())"
        cell.name.text = movie.title
        cell.releaseDate.text = DateUtils.convertToMonthAndYearFormat(from: movie.releaseDate)
    }
    
    func didTapBookmarkButton(_ cell: MovieCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let movie = popularMoviesViewModel.movieList[indexPath.row]
            popularMoviesViewModel.toggleBookmark(for: movie)
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
