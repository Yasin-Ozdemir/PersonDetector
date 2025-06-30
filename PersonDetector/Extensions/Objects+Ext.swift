//
//  Objects+Ext.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 27.06.2025.
//

import Foundation
import RealmSwift

extension Object {
    // Her @Persisted property tek tek okunur ve yeni nesneye aktarılır. Bağımsız realme bağlı olmayan bir kopya oluşur.
    
    func detached() -> Self {
        let detachedObject = Self()
        for property in objectSchema.properties {
            detachedObject.setValue(self.value(forKey: property.name), forKey: property.name)
        }
        return detachedObject
    }
}

