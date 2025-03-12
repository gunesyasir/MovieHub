//
//  UICollectionViewCell.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

extension UICollectionViewCell {
    func setBorder(radius: CGFloat, borderWidth: CGFloat = 0, borderColor: CGColor = UIColor.white.withAlphaComponent(0).cgColor) {
        contentView.layer.cornerRadius = radius
        contentView.layer.borderWidth = borderWidth
        contentView.layer.borderColor = borderColor
        contentView.layer.masksToBounds = true
        
        layer.cornerRadius = radius
    }
    
    func setShadowAndBorder(
        radius: CGFloat,
        borderWidth: CGFloat,
        borderColor: CGColor,
        shadowColor: CGColor,
        shadowRadius: CGFloat,
        bounds: CGRect
    ) {
        contentView.layer.cornerRadius = radius
        contentView.layer.borderWidth = borderWidth
        contentView.layer.borderColor = borderColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = shadowColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        layer.cornerRadius = radius
    }
}
