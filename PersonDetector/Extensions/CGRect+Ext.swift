//
//  CGRect+Ext.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 4.07.2025.
//
import Foundation

extension CGRect{
    func calculate(for imageSize : CGSize , currentSize : CGSize ) -> CGRect {
        let xRatio = (imageSize.width / currentSize.width)
        let yRatio = (imageSize.height / currentSize.height)
        
        let xmin = self.minX * xRatio
        let ymin = self.minY  * yRatio
        let xmax = self.maxX * xRatio
        let ymax = self.maxY  * yRatio

        return CGRect(x: xmin, y: ymin, width: xmax - xmin, height: ymax - ymin)
    }
}
