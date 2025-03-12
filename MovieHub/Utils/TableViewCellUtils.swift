//
//  TableViewCellUtils.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

struct TableViewCellUtils {
    static func modifySeparators(at indexPath: IndexPath, listLength: Int, insetDimension: Float, topInset: NSLayoutConstraint, bottomInset: NSLayoutConstraint) {
        if indexPath.row == 0 && listLength == 1 {
            topInset.constant = 0
            bottomInset.constant = 0
        } else if indexPath.row == 0 {
            topInset.constant = 0
            bottomInset.constant = CGFloat(insetDimension)
        } else if indexPath.row == listLength - 1 {
            topInset.constant = CGFloat(insetDimension)
            bottomInset.constant = 0
        } else {
            topInset.constant = CGFloat(insetDimension)
            bottomInset.constant = CGFloat(insetDimension) 
        }
    }
}
