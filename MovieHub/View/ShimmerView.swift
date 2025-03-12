//
//  ShimmerView.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

class ShimmerView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let animationDuration: CFTimeInterval = 1.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShimmer()
    }
    
    private func setupShimmer() {
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.8).cgColor,
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0.8).cgColor
        ]
        
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.5, 1.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = animationDuration
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
