//
//  PersonDetector.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 24.06.2025.
//

import Foundation
import TensorFlowLite


enum PersonDetectorError: Error {
    case detectionFailed
    case noPerson
}

protocol PersonDetectorProtocol {
    func setupYolomodel(inputWidth: CGFloat, inputHeight: CGFloat, confidenceThreshold: Float) throws
    func detectPerson(with image: UIImage) async throws -> DetectedModel
}

class PersonDetector: PersonDetectorProtocol {
    private var interpreter: Interpreter?

    private var inputWidth : CGFloat = 0
    private var inputHeight : CGFloat = 0
    private var confidenceThreshold: Float = 0
    
    func setupYolomodel(inputWidth: CGFloat, inputHeight: CGFloat, confidenceThreshold: Float) throws {
        guard let modelPath = Bundle.main.path(forResource: "person-det 1", ofType: "tflite") else {
            print("Model bulunamadı")
            return
        }
        // interpreter options threadlere bak
        var options = Interpreter.Options()
        options.threadCount = 2 // 1 : 0.711 - 2: 0.58 - 3: 0.56 - 4: 0.54
        // options.isXNNPackEnabled = true | high-performance kernel library|  MODEL DESTEKLEMİYOR :(
        interpreter = try Interpreter(modelPath: modelPath, options: options)
        try interpreter?.allocateTensors()
        
        self.inputWidth = inputWidth
        self.inputHeight = inputHeight
        self.confidenceThreshold = confidenceThreshold
        print("Model başarıyla yüklendi!")

    }


    func detectPerson(with image: UIImage) async throws -> DetectedModel {
        let startTime = Date()
        guard let inputData = preprocess(image: image), let interpreter = interpreter else {
            throw PersonDetectorError.detectionFailed
        }

        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DetectedModel, Error>) in

            do {
                try interpreter.copy(inputData, toInputAt: 0)
                try interpreter.invoke()

                let boxes = try interpreter.output(at: 0).data.toArray(type: Float32.self)
                let confidences = try interpreter.output(at: 1).data.toArray(type: Float32.self)

                var predictions: [Detection] = []

                for i in 0..<confidences.count {
                    if confidences[i] > 0.3 {
                        let box = Array(boxes[i * 4..<i * 4 + 4])
                        let rect = CGRect(x: CGFloat(box[0]),y: CGFloat(box[1]),width: CGFloat(box[2] - box[0]),height: CGFloat(box[3] - box[1]))

                        predictions.append(Detection(score: confidences[i], rect: rect))
                    }
                }
                print("NMS işlemi öncesi: ", predictions)
                let finalPredictions = nonMaximumSuppression(predictions: predictions)
                print("NMS işlemi sonrası: " , finalPredictions)
               
                
                let detectedModel = DetectedModel(image: setupImage(image)!, rect: finalPredictions.first!.rect)
                continuation.resume(returning: detectedModel)

            } catch {
                continuation.resume(throwing: PersonDetectorError.detectionFailed)
            }

        }
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        print("Süre: \(duration) saniye")

        return result
    }


    private func preprocess(image: UIImage) -> Data? {
        guard let image = setupImage(image) else {
            return nil
        }

        guard let rgbData = image.rgbData() else {
            print("RGB verisi oluşturulamadı.")
            return nil
        }

        return rgbData
    }

    private func setupImage(_ image: UIImage) -> UIImage? {
        let fixedImage = image.upright()
        guard let resizedImage = fixedImage.resize(to: CGSize(width: inputWidth, height: inputHeight)) else {
            print("Resim yeniden boyutlandırılamadı.")
            return nil
        }
        return resizedImage
    }

    private func nonMaximumSuppression(predictions: [Detection], iouThreshold: Float = 0.3) -> [Detection] {
        var sorted = predictions.sorted { $0.score > $1.score }
       
        /* Birden fazla insan varsa iou işlemi yapılarak best confidence sahip bounding box ile üst üste gelmeyen bounding boxları listede tutar (farklı insan), üst üste gelen boxları listeden çıkarır (aynı insana ait diğer bounding boxlar).*/
        
        var result : [Detection] = []
         
        while !sorted.isEmpty {
            let best = sorted.removeFirst()
            result.append(best)

            sorted = sorted.filter {
                iou($0.rect, best.rect) > iouThreshold
            }
        }

        return result
    }

    private func iou(_ a: CGRect, _ b: CGRect) -> Float {
        let intersection = a.intersection(b)
        let intersectionArea = intersection.width * intersection.height
        let unionArea = a.width * a.height + b.width * b.height - intersectionArea
        return Float(intersectionArea / unionArea)
    }

}
