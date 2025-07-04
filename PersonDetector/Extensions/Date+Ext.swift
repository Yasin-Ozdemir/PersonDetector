//
//  Date+Ext.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 30.06.2025.
//

import Foundation

extension Date{
   static func getCurrentDay() -> String{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.MM.yyyy"
        
        let todayDate = dateFormatter.string(from: date)
        return todayDate
    }
}
