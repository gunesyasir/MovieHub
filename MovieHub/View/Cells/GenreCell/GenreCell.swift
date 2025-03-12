//
//  GenreCell.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

class GenreCell: UICollectionViewCell {
    @IBOutlet weak var genreLabel: UILabel!
    
    static func getNib() -> UINib {
        return UINib(nibName: String(describing: GenreCell.self), bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
