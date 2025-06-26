//
//  String+Ext.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 26.06.2025.
//
import Foundation

extension String {
    var localized: String {
           return NSLocalizedString(self, comment: "")
       }
    func localized(with arguments: CVarArg...) -> String {
            let format = NSLocalizedString(self, comment: "")
            return String(format: format, arguments: arguments)
        }
}

// öncesine sayfa collection view her resim kaydedilcek Realm kullanılcak.
// persen detected ise fotoğraf çekme sayfasına
// kişi yoksa detay sayfası yok
// cellin içinde resim ve tarih
