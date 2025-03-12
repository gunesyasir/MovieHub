//
//  UINavigationBar.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

extension UINavigationBar {
    func setTitleAlpha(_ alpha: CGFloat) {
        let currentTitleAttributes = self.titleTextAttributes ?? [:]
        
        let currentColor = (currentTitleAttributes[.foregroundColor] as? UIColor) ?? UIColor.black
        
        let newColor = currentColor.withAlphaComponent(alpha)

        self.titleTextAttributes = [
            .foregroundColor: newColor
        ]
    }
}

