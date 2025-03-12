//
//  UIView.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

extension UIView {
    func addShimmer() {
        let shimmerView = ShimmerView(frame: self.bounds)
        self.addSubview(shimmerView)
    }
    
    func removeShimmer() {
        self.subviews.forEach { view in
            if view is ShimmerView {
                view.removeFromSuperview()
            }
        }
    }
}
