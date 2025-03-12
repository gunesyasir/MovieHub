//
//  MovieTableViewCell.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit
import SwipeCellKit

class MovieTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var topInset: NSLayoutConstraint!
    @IBOutlet weak var bottomInset: NSLayoutConstraint!
    
    static func getNib() -> UINib {
        return UINib(nibName: String(describing: MovieTableViewCell.self), bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
