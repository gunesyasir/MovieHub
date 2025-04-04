//
//  MovieDetailController+CollectionView.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

extension MovieDetailController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           
        if collectionView == genreCollection {
            return viewModel.movie.genres.count
        } else if collectionView == castCollection {
            return viewModel.isCastRequestCompleted ? viewModel.movie.cast.count : 10 // Default skeleton container count
        } else { // Recommendations collection
            return viewModel.isRecommendedsRequestCompleted ? viewModel.movie.recommendedMovies.count : 10 // Default skeleton container count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == genreCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GenreCell.self), for: indexPath) as! GenreCell
            cell.genreLabel.text = viewModel.movie.genres[indexPath.row].name ?? ""
            cell.setBorder(radius: 8)
            return cell
        } else { // Cast and Recommendations collection
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ContentCell.self), for: indexPath) as! ContentCell
            
            let isCast = collectionView == castCollection
            let castList = viewModel.movie.cast
            let movieList = viewModel.movie.recommendedMovies
            
            if isCast && !viewModel.isCastRequestCompleted || !isCast && !viewModel.isRecommendedsRequestCompleted {
                cell.addShimmer()
                return cell
            }
            cell.removeShimmer()
            
            let url = ImageUtils.getImageURL(from: isCast ? castList[indexPath.row].profilePath : movieList[indexPath.row].posterPath)
            cell.image.setImage(with: url)
            
            cell.title.text = isCast ? castList[indexPath.row].name : movieList[indexPath.row].title
            cell.subtitle.text = isCast ? castList[indexPath.row].character : ""
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == recommendationsCollection, indexPath.row == viewModel.movie.recommendedMovies.count - 1, viewModel.recommendedsCurrentPageCount < viewModel.recommendedsTotalPageCount {
            viewModel.fetchRecommendations()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == recommendationsCollection {
            fetchMovieDetail(of: viewModel.movie.recommendedMovies[indexPath.row].id)
        } else if collectionView == castCollection {
            fetchCastDetail(of: viewModel.movie.cast[indexPath.row].id)
        }
    }
}
