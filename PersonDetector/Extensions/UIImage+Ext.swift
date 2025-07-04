//
//  UIImage+Ext.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 24.06.2025.
//

import UIKit
enum BlurLevel : Int {
    case low = 20
    case mid = 40
    case high = 60
}
extension UIImage {

    func upright() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? self
    }

    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }

    func rgbData() -> Data? {
        guard let cgImage = self.cgImage else { return nil }

        let width = Int(self.size.width)
        let height = Int(self.size.height)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow

        var rgbaBuffer = [UInt8](repeating: 0, count: totalBytes)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(data: &rgbaBuffer,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else {
            print("Yeni CGContext oluşturulamadı.")
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))


        var rgbBuffer = [UInt8]()
        for i in stride(from: 0, to: rgbaBuffer.count, by: 4) {
            rgbBuffer.append(rgbaBuffer[i]) // R
            rgbBuffer.append(rgbaBuffer[i + 1]) // G
            rgbBuffer.append(rgbaBuffer[i + 2]) // B
        }

        return Data(rgbBuffer)
    }
    
    
    func blur(rect : CGRect , level : BlurLevel) -> UIImage?{
        guard  let ciImage = CIImage(image: self) else {
          return nil
      }

      let context = CIContext()
      var outputImage = ciImage
     
   
     
      let cropped = ciImage.cropped(to: rect)
      let blurred = cropped
            .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: level.rawValue])
          .cropped(to: rect)


      outputImage = blurred.composited(over: outputImage)


      if let finalCG = context.createCGImage(outputImage, from: outputImage.extent) {
          return UIImage(cgImage: finalCG)
      }

      return nil
    }

}
