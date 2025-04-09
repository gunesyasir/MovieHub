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

enum RealmObjectStatus {
    case exist
    case nonExist
}


/// Represents how a Realm object should be fetched.
/// - `managed`: Returns the object as-is from Realm, tied to its thread and lifecycle.
///              Use this option when you need to perform Realm operations on the object,
///              such as updating or deleting it (e.g., passing it to `deleteObject`).
/// - `detached`: Returns a copy of the object that is safe to use outside Realm (e.g., in ViewModels, UI logic, or across threads),
///               where Realm-managed objects would otherwise cause threading or lifecycle issues.
enum RealmFetchType {
    case managed
    case detached
}

enum Tabs: Int {
    case popular = 0
    case search = 1
    case bookmark = 2
}
