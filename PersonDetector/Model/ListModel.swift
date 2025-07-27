//
//  ListModel.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 27.06.2025.
//

import Foundation
import RealmSwift

final class ListModel : Object{
    /* coding keys ? :  JSONdaki anahtar isimleri ile modeldeki property isimleri farklıysa eşleştirme yapmak için kullanılır. Örnek kullanım :
     private enum CodingKeys: String, CodingKey {
     case id = "user_id"
     case date = "date"
     case imageData = "image_data"
 }*/
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var date: Date
    @Persisted var imageData : Data
    @Persisted var isPersonDetected : Bool
    
    convenience init( date: Date, imageData: Data , isPersonDetected: Bool) {
        self.init()
        self.date = date
        self.imageData = imageData
        self.isPersonDetected = isPersonDetected
    }
}
