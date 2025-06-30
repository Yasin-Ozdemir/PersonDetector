//
//  DatabaseManager.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 27.06.2025.
//
import Foundation
import RealmSwift

enum DatabaseError: Error {
    case saveError
    case deleteError
}

protocol DatabaseManagerProtocol {
    func save<T: Object>(_ object: T) async throws
    func delete<T: Object>(_ object: T) async throws
    func getAll<T: Object>(model: T.Type) async throws -> [T]
}

final class DatabaseManager: DatabaseManagerProtocol {
    // Realm hangi thread’de yaratıldıysa, sadece orada kullanılabilir. Bu yüzden kullanılacağı threadde yarat
    // coding keys ?
    // realm objesine variable ekle ?

    func save<T: Object>(_ object: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(object)
                }
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }


    func getAll<T: Object>(model: T.Type) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let realm = try Realm()
                let results = realm.objects(model)
                let detachedArray = results.map { $0.detached() }
                continuation.resume(returning: Array(detachedArray))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }


    func delete<T: Object>(_ object: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do{
                let realm = try Realm()
                try realm.write {
                    realm.delete(object)
                }
                continuation.resume()
            }catch {
                continuation.resume(throwing: error)
            }
        }
    }


}
