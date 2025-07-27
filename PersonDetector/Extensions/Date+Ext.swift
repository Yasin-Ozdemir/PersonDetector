//
//  Date+Ext.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 30.06.2025.
//

import Foundation

extension Date{
    func getDay() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let dayDate = dateFormatter.string(from: self)
        return dayDate
    }
}
