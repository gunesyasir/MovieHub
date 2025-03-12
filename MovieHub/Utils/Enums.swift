//
//  Enums.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

enum RealmCollectionChangeStatus {
    case initial
    case update(deletions: [IndexPath], insertions: [IndexPath], modifications: [IndexPath])
}

enum MovieAppError: Error {
    case error(message: String?)
}

enum RealmObjectChangeStatus {
    case change
    case delete
}

enum Tabs: Int {
    case popular = 0
    case search = 1
    case bookmark = 2
}
