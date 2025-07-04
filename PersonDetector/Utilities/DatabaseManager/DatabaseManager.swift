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
    func delete<T: Object>( modelType: T.Type , id: ObjectId ) async throws 
    func getAll<T: Object>(model: T.Type)  throws -> Results<T>
}

final class DatabaseManager: DatabaseManagerProtocol {
    /*
     realm objesine variable ekle ? : Schema versiyonu arttırılır ve eğer yeni eklenen propertynin default değeri yoksa migration yapılarak kayıtlı nesnelere bu property manuel eklenir aksi takdirde crash olur.
     */

    func save<T: Object>(_ object: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(object)
                    print("save success")
                }
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }


    func getAll<T: Object>(model: T.Type)  throws -> Results<T> {
      
                let realm = try Realm()
                let results = realm.objects(model)
               
               return results
            
    }


    func delete<T: Object>( modelType: T.Type , id: ObjectId ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do{
                let realm = try Realm()
                guard let object = realm.object(ofType: modelType, forPrimaryKey: id) else {
                    return
                }
                
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
