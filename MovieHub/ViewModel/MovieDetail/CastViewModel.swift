//
//  CastViewModel.swift
//  MovieHub
//
//  Created by Yasir Gunes on 8.04.2025.
//

import Foundation

struct CastViewModel: MovieDetailCollectionContentPresentable {
    var id: Int
    var titleText: String?
    var subtitleText: String?
    var imageURL: URL?
    
    init(cast: Cast) {
        self.id = cast.id
        self.titleText = cast.name
        self.subtitleText = cast.character
        self.imageURL = ImageUtils.getImageURL(from: cast.profilePath)
    }
}
