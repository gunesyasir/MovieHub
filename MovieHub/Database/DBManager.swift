//
//  DBManager.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//
import Foundation
import RealmSwift
import Combine

enum DBManagerError: Error {
    case initializationFailed
    case operationFailed
}

enum RealmCollectionChangeStatusNew<Model: Object> {
    case initial([Model])
    case update(newCollection: [Model], deletions: [Int], insertions: [Int], modifications: [Int])
}

protocol DBManagerProtocol {
    associatedtype Model: Object
    var realm: Realm? { get }

    func saveObject(_ object: Model, completion: @escaping (Result<Void, DBManagerError>) -> Void)
    func deleteObject(primaryKey: Any, completion: @escaping (Result<Void, DBManagerError>) -> Void)
    func fetchObjectByPrimaryKey(primaryKey: Any, fetchType: RealmFetchType, completion: @escaping (Result<Model?, DBManagerError>) -> Void)
    func fetchAllObjects(completion: @escaping (Result<[Model], DBManagerError>) -> Void)
    func isObjectInDatabase(primaryKey: Any, completion: @escaping (Result<Bool, DBManagerError>) -> Void)

    func observeCollectionPublisher(notificationToken: inout NotificationToken?) -> AnyPublisher<RealmCollectionChangeStatusNew<Model>, Never>
    func observeCollection(notificationToken: inout NotificationToken?, completion: @escaping (Result<RealmCollectionChangeStatus, DBManagerError>) -> Void)
    func observeObject(for primaryKey: Any, objectNotificationToken: inout NotificationToken?, completion: @escaping (Result<RealmObjectStatus, DBManagerError>) -> Void)
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
    
    func fetchObjectByPrimaryKey(primaryKey: Any, fetchType: RealmFetchType = .managed, completion: @escaping (Result<Model?, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        let object = realm.object(ofType: Model.self, forPrimaryKey: primaryKey)
        
        switch fetchType {
        case .managed:
            completion(.success(object))
        case .detached:
            if let object = object {
                let detachedObject = object.detached()
                completion(.success(detachedObject))
            } else {
                completion(.success(nil))
            }
        }
    }
    
    func fetchAllObjects(completion: @escaping (Result<[Model], DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        let objects = Array(realm.objects(Model.self))
        completion(.success(objects))
    }
    
    func fetchAllObjectsNew() -> Array<Model> {
        guard let realm = realm else { return [] }
        return Array(realm.objects(Model.self))
    }

    func isObjectInDatabase(primaryKey: Any, completion: @escaping (Result<Bool, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }

        let exists = realm.object(ofType: Model.self, forPrimaryKey: primaryKey) != nil
        completion(.success(exists))
    }
    
    func observeCollectionPublisher(notificationToken: inout NotificationToken?) -> AnyPublisher<RealmCollectionChangeStatusNew<Model>, Never> {
        let subject = PassthroughSubject<RealmCollectionChangeStatusNew<Model>, Never>()
        
        guard let realm = realm else { return subject.eraseToAnyPublisher()}
        
        let results = realm.objects(Model.self)
        
        notificationToken = results.observe(on: .main) { changes in
            switch changes {
            case .initial(let collection):
                subject.send(.initial(Array(collection)))
            case .update(let newCollection, let deletions, let insertions, let modifications):
                subject.send(.update(newCollection: Array(newCollection), deletions: deletions, insertions: insertions, modifications: modifications))
            case .error(_): break
            }
        }
        
        return subject.eraseToAnyPublisher()
    }

    func observeCollection(notificationToken: inout NotificationToken?, completion: @escaping (Result<RealmCollectionChangeStatus, DBManagerError>) -> Void) {
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
            case .error(_):
                completion(.failure(.operationFailed))
            }
        }
    }

    func observeObject(for primaryKey: Any, objectNotificationToken: inout NotificationToken?, completion: @escaping (Result<RealmObjectStatus, DBManagerError>) -> Void) {
        guard let realm = realm else {
            completion(.failure(.initializationFailed))
            return
        }
        
        let results = realm.objects(Model.self).filter("id == %@", primaryKey)
        objectNotificationToken = results.observe { changes in
            switch changes {
            case .initial(let objects):
                completion(.success(objects.count > 0 ? .exist : .nonExist))
                break
            case .update(_, let deletions, let insertions, let modifications):
                if !insertions.isEmpty || !modifications.isEmpty {
                    completion(.success(.exist))
                } else if !deletions.isEmpty {
                    completion(.success(.nonExist))
                }
                break
            case .error(_):
                completion(.failure(.operationFailed))
                break
            }
        }
    }
}

struct MovieDBManager: DBManagerProtocol {
    typealias Model = Movie
    static let shared = MovieDBManager()
    private init() {}
}
