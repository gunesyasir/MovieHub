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
            return viewModel.isCastRequestCompleted ? viewModel.castList.count : 10 // Default skeleton container count
        } else { // Recommendations collection
            return viewModel.isRecommendedsRequestCompleted ? viewModel.recommendedMovieList.count : 10 // Default skeleton container count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == genreCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GenreCell.self), for: indexPath) as! GenreCell
            cell.genreLabel.text = viewModel.genreName(at: indexPath.row)
            cell.setBorder(radius: 8)
            return cell
        } else { // Cast and Recommendations collection
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ContentCell.self), for: indexPath) as! ContentCell
            
            let isCast = collectionView == castCollection
            
            if isCast && !viewModel.isCastRequestCompleted || !isCast && !viewModel.isRecommendedsRequestCompleted {
                cell.addShimmer()
                return cell
            }
            cell.removeShimmer()
            
            let item: MovieDetailCollectionContentPresentable? = isCast ? viewModel.castItem(at: indexPath.row) : viewModel.recommendedMovieItem(at: indexPath.row)
            guard let item = item else { return cell }
            
            cell.image.setImage(with: item.imageURL)
            cell.title.text = item.titleText
            cell.subtitle.text = item.subtitleText
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == recommendationsCollection {
            viewModel.fetchRecommendations(at: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == recommendationsCollection {
            let movieId = viewModel.movie.recommendedMovies[indexPath.row].id
            fetchMovieDetail(of: movieId)
        } else if collectionView == castCollection {
            let actorId = viewModel.movie.cast[indexPath.row].id
            viewModel.fetchActorDetail(of: actorId)
        }
    }
}

protocol MovieDetailCollectionContentPresentable {
    var id: Int { get }
    var titleText: String? { get }
    var subtitleText: String? { get }
    var imageURL: URL? { get }
}
