//
//  ActorDetailController.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import UIKit

final class ActorDetailController: BaseViewController {
    @IBOutlet weak var actorImage: UIImageView!
    @IBOutlet weak var actorName: UILabel!
    @IBOutlet weak var biography: UILabel!
    @IBOutlet weak var birthdayPlace: UILabel!
    @IBOutlet weak var deathDay: UILabel!
    
    let actor: Cast
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    init?(coder: NSCoder, actor: Cast) {
        self.actor = actor
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use `init(coder:actor:)` to initialize.")
    }
    
    private func setUpViews() {
        actorName.text = actor.name
        
        let imageUrl = ImageUtils.getImageURL(from: actor.profilePath)
        actorImage.setImage(with: imageUrl)
        
        if let day = actor.birthday, let place = actor.placeOfBirth {
            birthdayPlace.text = "\(LocalizedStrings.birthPlaceAndDate.localized)\(DateUtils.convertToMonthAndYearFormat(from: day)) - \(place)"
        } else if let date = actor.birthday {
            birthdayPlace.text = "\(LocalizedStrings.birthDate.localized)\(DateUtils.convertToMonthAndYearFormat(from: date))"
        } else if let place = actor.placeOfBirth {
            birthdayPlace.text = "\(LocalizedStrings.birthPlace.localized)\(place)"
        } else {
            birthdayPlace.removeFromSuperview()
        }
        
        if let date = actor.deathday {
            deathDay.text = "\(LocalizedStrings.deathDate.localized)\(DateUtils.convertToMonthAndYearFormat(from: date))"
        } else {
            deathDay.removeFromSuperview()
        }
        
        if let actorBiography = actor.biography {
            biography.text = actorBiography
        } else {
            biography.removeFromSuperview()
        }
        
    }

}
