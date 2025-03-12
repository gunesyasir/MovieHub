//
//  MovieCollectionViewCell.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

protocol MovieCellDelegate {
    func didTapBookmarkButton(_ cell: MovieCollectionViewCell)
}

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    
    var isBookmarked: Bool = false {
        didSet {
            updateCellUI()
        }
    }
    
    var delegate: MovieCellDelegate?
    
    let addButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 50))
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        addButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        addButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setupButton() {
        addButton.frame = CGRect(x: 0, y: 0, width: 30, height: 50)
        
        let path = UIBezierPath(rect: addButton.bounds)
        
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: 0, y: 50))
        trianglePath.addLine(to: CGPoint(x: 15, y: 40))
        trianglePath.addLine(to: CGPoint(x: 30, y: 50))
        trianglePath.close()
        
        path.append(trianglePath)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        
        addButton.layer.mask = maskLayer
        
        contentView.addSubview(addButton)
    }
    
    private func updateCellUI() {
        if isBookmarked {
            addButton.backgroundColor = .yellow.withAlphaComponent(0.8)
            addButton.setImage(UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
            addButton.tintColor = .black
        } else {
            addButton.backgroundColor = .black.withAlphaComponent(0.5)
            addButton.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
            addButton.tintColor = .white
        }
    }
    
    @objc private func bookmarkTapped() {
        delegate?.didTapBookmarkButton(self)
    }

}
