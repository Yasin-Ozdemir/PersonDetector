//
//  ListModel.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 27.06.2025.
//

import Foundation
import RealmSwift

final class ListModel : Object{
    // Persisted anlamı? : Realme bu property'sinin kalıcı olarak saklanacağını bildirir. @Persisted sayesinde Realm bu değişkenlerin değişimini otomatik olarak takip edebilir ve güncelleyebilir. v10 dan sonra zorunlu!
    
    //Eğer bir property realme kaydedilmesin ama sınıfta bulunsun istiyorsan, onu @Ignored olarak işaretleyebilirsin
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var date: String
    @Persisted var imageData : Data
    @Persisted var isPersonDetected : Bool
    
    convenience init( date: String, imageData: Data , isPersonDetected: Bool) {
        self.init()
        self.date = date
        self.imageData = imageData
        self.isPersonDetected = isPersonDetected
    }
}
