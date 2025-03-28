//
//  DBManager.swift
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

protocol DBManagerProtocol {
    associatedtype Model: Object
    var realm: Realm? { get }

    func saveObject(_ object: Model, completion: @escaping (Result<Void, DBManagerError>) -> Void)
    func deleteObject(primaryKey: Any, completion: @escaping (Result<Void, DBManagerError>) -> Void)
    func fetchObjectByPrimaryKey(primaryKey: Any, completion: @escaping (Result<Model?, DBManagerError>) -> Void)
    func fetchAllObjects(completion: @escaping (Result<[Model], DBManagerError>) -> Void)
    func isObjectInDatabase(primaryKey: Any, completion: @escaping (Result<Bool, DBManagerError>) -> Void)

    func observeChanges(notificationToken: inout NotificationToken?, completion: @escaping (Result<RealmCollectionChangeStatus, DBManagerError>) -> Void)
    func observeObject(for primaryKey: Any, objectNotificationToken: inout NotificationToken?, completion: @escaping (Result<RealmObjectChangeStatus, DBManagerError>) -> Void)
}

extension DBManagerProtocol {
    
    var realm: Realm? {
        return try? Realm()
    }
    
    func saveObject(_ object: Model, completion: @escaping (Result<Void, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        do {
            try realm.write {
                realm.create(Model.self, value: object, update: .modified)
            }
            completion(.success(()))
        } catch {
            debugPrint("Failed to save object: \(error.localizedDescription)")
            completion(.failure(.operationFailed))
        }
    }

    func deleteObject(primaryKey: Any, completion: @escaping (Result<Void, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        guard let object = realm.object(ofType: Model.self, forPrimaryKey: primaryKey) else {
            completion(.failure(.operationFailed))
            return
        }
        
        do {
            try realm.write {
                realm.delete(object)
            }
            completion(.success(()))
        } catch {
            debugPrint("Failed to delete object: \(error.localizedDescription)")
            completion(.failure(.operationFailed))
        }
    }
    
    func fetchObjectByPrimaryKey(primaryKey: Any, completion: @escaping (Result<Model?, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        let object = realm.object(ofType: Model.self, forPrimaryKey: primaryKey)
        completion(.success(object))
    }
    
    func fetchAllObjects(completion: @escaping (Result<[Model], DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        let objects = Array(realm.objects(Model.self))
        completion(.success(objects))
    }

    func isObjectInDatabase(primaryKey: Any, completion: @escaping (Result<Bool, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }

        let exists = realm.object(ofType: Model.self, forPrimaryKey: primaryKey) != nil
        completion(.success(exists))
    }

    func observeChanges(notificationToken: inout NotificationToken?, completion: @escaping (Result<RealmCollectionChangeStatus, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }

        let results = realm.objects(Model.self)

        notificationToken = results.observe(on: .main) { changes in
            switch changes {
            case .initial:
                completion(.success(.initial))
            case .update(_, let deletions, let insertions, let modifications):
                let deletions: [IndexPath] = deletions.map { IndexPath(row: $0, section: 0) }
                let insertions: [IndexPath] = insertions.map { IndexPath(row: $0, section: 0) }
                let modifications: [IndexPath] = modifications.map { IndexPath(row: $0, section: 0) }
                completion(.success(.update(deletions: deletions, insertions: insertions, modifications: modifications)))
            case .error(let error):
                completion(.failure(.operationFailed))
            }
        }
    }

    func observeObject(for primaryKey: Any, objectNotificationToken: inout NotificationToken?, completion: @escaping (Result<RealmObjectChangeStatus, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }

        guard let object = realm.object(ofType: Model.self, forPrimaryKey: primaryKey) else {
            completion(.failure(.operationFailed))
            return
        }

        objectNotificationToken = object.observe { change in
            switch change {
            case .change(_, _):
                completion(.success(.change))
            case .deleted:
                completion(.success(.delete))
            case .error(let error):
                completion(.failure(.operationFailed))
            }
        }
    }
}

struct DBManager: DBManagerProtocol {
    typealias Model = Movie
    static let shared = DBManager()
    private init() {}
}
