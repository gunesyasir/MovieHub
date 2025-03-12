//
//  UIApplication.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

extension UIApplication {
    var safeAreaInsets: UIEdgeInsets? {
        if #available(iOS 15, *) {
            return connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .last?.safeAreaInsets
        } else {
            // Fallback on earlier versions
            return nil
        }
    }
}
