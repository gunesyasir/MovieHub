//
//  AppDelegate.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation
import RealmSwift

enum DBManagerError: Error {
    case initializationFailed
    case operationFailed
}

class DBManager<T: Object> {
    
    static var shared: DBManager<T>? {
        return DBManager()
    }
    
    private let realm: Realm?
    private var notificationToken: NotificationToken?
    
    private init?() {
        do {
            realm = try Realm()
        } catch {
            debugPrint("Failed to initialize Realm: \(error.localizedDescription)")
            realm = nil
        }
    }
    
    func deleteObject(primaryKey: Any, completion: @escaping (Result<Void, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        do {
            // Realm doesn't permit to delete copies of object so we first fetch object then delete it.
            let object = realm.object(ofType: T.self, forPrimaryKey: primaryKey)
            guard let object = object else {
                completion(.failure(.operationFailed))
                return
            }
            
            try realm.write {
                realm.delete(object)
            }
            completion(.success(()))
        } catch {
            debugPrint("Failed to delete object: \(error.localizedDescription)")
            completion(.failure(.operationFailed))
        }
    }
    
    func fetchObjectByPrimaryKey(primaryKey: Any, completion: @escaping (Result<T?, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        let object = realm.object(ofType: T.self, forPrimaryKey: primaryKey)
        
        completion(.success(object))
    }
    
    func fetchAllObjects(completion: @escaping (Result<[T], DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        let list = Array(realm.objects(T.self))
        completion(.success(list))
    }
    
    func isObjectInDatabase(primaryKey: Any, completion: @escaping (Result<Bool, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        let isExists = realm.object(ofType: T.self, forPrimaryKey: primaryKey) != nil
        completion(.success(isExists))
    }
    
    func observeChanges(notificationToken: inout NotificationToken?, completion: @escaping (Result<RealmCollectionChangeStatus, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        let results = realm.objects(T.self)
        
        notificationToken = results.observe(on: .main) { changes in
            switch changes {
                case .initial:
                    completion(.success(.initial))
                case .update(_, let deletions, let insertions, let modifications):
                    let deletions: [IndexPath] = deletions.map { IndexPath(row: $0, section: 0) }
                    let insertions: [IndexPath] = insertions.map { IndexPath(row: $0, section: 0) }
                    let modifications: [IndexPath] = modifications.map { IndexPath(row: $0, section: 0) }
                    completion(.success(.update(deletions: deletions, insertions: insertions, modifications: modifications)))
                case .error(_):
                    completion(.failure(.operationFailed))
            }
        }
        
    }
    
    func observeObject(for primaryKey: Any, objectNotificationToken: inout NotificationToken?, completion: @escaping (Result<RealmObjectChangeStatus, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        let object = realm.object(ofType: T.self, forPrimaryKey: primaryKey)
        
        guard let object = object else {
            completion(.failure(.operationFailed))
            return
        }
        
        objectNotificationToken = object.observe { change in
            switch change {
                case .change(_, _):
                    completion(.success(.change))
                case .error(_):
                    completion(.failure(.operationFailed))
                case .deleted:
                    completion(.success(.delete))
            }
        }
    }
    
    func saveObject(_ object: T, completion: @escaping (Result<Void, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        do {
            try realm.write {
                realm.create(T.self, value: object, update: .modified)
            }
            completion(.success(()))
        } catch {
            debugPrint("Failed to save object: \(error.localizedDescription)")
            completion(.failure(.operationFailed))
        }
    }
    
}
