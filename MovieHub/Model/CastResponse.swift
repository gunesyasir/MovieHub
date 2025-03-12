//
//  CastResponse.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation
import RealmSwift

struct CastResponse: Codable {
    let id: Int
    let cast, crew: [Cast]
}

class Cast: Object, Codable {
    @Persisted var id: Int
    @Persisted var name: String?
    @Persisted var biography: String?
    @Persisted var birthday: String?
    @Persisted var deathday: String?
    @Persisted var placeOfBirth: String?
    @Persisted var character: String?
    @Persisted var profilePath: String?
    @Persisted var role: String?
    
    enum CodingKeys: String, CodingKey {
        case id, biography, birthday, character, deathday, name
        case placeOfBirth = "place_of_birth"
        case profilePath = "profile_path"
        case role = "known_for_department"
    }
}
