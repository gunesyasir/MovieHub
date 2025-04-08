//
//  RecommendedMovieViewModel.swift
//  MovieHub
//
//  Created by Yasir Gunes on 8.04.2025.
//

import Foundation

struct RecommendedMovieViewModel: MovieDetailCollectionContentPresentable {
    let id: Int
    let titleText: String?
    let subtitleText: String? = ""
    let imageURL: URL?

    init(movie: RecommendedMovie) {
        self.id = movie.id
        self.titleText = movie.title
        self.imageURL = ImageUtils.getImageURL(from: movie.posterPath)
    }
}
