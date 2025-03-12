//
//  NavigationUtils.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

class NavigationUtils {
    static func navigateToActorDetail(from viewController: UIViewController, actor: Cast) {
        let identifier = String(describing: ActorDetailController.self)
        
        if let vc = viewController.storyboard?.instantiateViewController(identifier: identifier, creator: { coder -> ActorDetailController? in
            ActorDetailController(coder: coder, actor: actor)
        }) {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    static func navigateToMovieDetail(from viewController: UIViewController, movie: Movie) {
        let identifier = String(describing: MovieDetailController.self)
        
        if let vc = viewController.storyboard?.instantiateViewController(identifier: identifier, creator: { coder -> MovieDetailController? in
            MovieDetailController(coder: coder, movie: movie)
        }) {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

