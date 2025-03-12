//
//  MovieDetailController+ScrollView.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

extension MovieDetailController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y

        let alpha: CGFloat = {
            guard let insets = UIApplication.shared.safeAreaInsets, offset > 0 else {
                return 0
            }
            
            return insets.top == 0 ? 1 : max(0, 1 - (insets.top / offset))
        }()

        navigationController?.navigationBar.setTitleAlpha(alpha)
    }
}
