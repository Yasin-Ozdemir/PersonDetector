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

final class PersonDetector: PersonDetectorProtocol {
    private var interpreter: Interpreter?

    private var inputWidth : CGFloat = 0
    private var inputHeight : CGFloat = 0
    private var confidenceThreshold: Float = 0
    
    func setupYolomodel(inputWidth: CGFloat, inputHeight: CGFloat, confidenceThreshold: Float) throws {
        guard let modelPath = Bundle.main.path(forResource: "newest_person_det_model", ofType: "tflite") else {
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
        guard let inputImage = setupImage(image) ,let inputData : Data = inputImage.rgbData(), let interpreter else {
            throw PersonDetectorError.detectionFailed
        }

        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DetectedModel, Error>) in

            do {
                try interpreter.copy(inputData, toInputAt: 0)
                try interpreter.invoke()

                let boxes : [Float] = try interpreter.output(at: 0).data.toArray(type: Float.self)
                let confidences  : [Float] = try interpreter.output(at: 1).data.toArray(type: Float.self)
                
            
                
                let detections : [Detection] = self.filterDetections(boxes: boxes, confidences: confidences)
                                
                guard  !detections.isEmpty else {
                    continuation.resume(throwing: PersonDetectorError.noPerson)
                    return
                }
               
                let finalPredictions : [Detection] = nonMaximumSuppression(predictions: detections)
             
                
                let detectedModel = DetectedModel(image: inputImage, rect: finalPredictions[0].rect)
                continuation.resume(returning: detectedModel)

            } catch {
                continuation.resume(throwing: PersonDetectorError.detectionFailed)
            }

        }
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        print("Detect Süre: \(duration) saniye") // 0.38 sn civarı

        return result
    }


    private func setupImage(_ image: UIImage) -> UIImage? {
        let fixedImage = image.upright()
        
        guard let resizedImage = fixedImage.resize(to: CGSize(width: inputWidth, height: inputHeight)) else {
            print("Resim yeniden boyutlandırılamadı.")
            return nil
        }
        return resizedImage
    }

    
    private func filterDetections(boxes : [Float], confidences : [Float]) -> [Detection]{
        // Append başlangıçta küçük bir kapasiteyle başlar eleman eklendikçe resize yapılır. Büyük döngülerde çok maliyete sebep
        // reserveCapacity ile append hızlandırılabilir. (Boyutu önceden belirleme)
        // filter : her eleman için koşulu test eder true dönenleri yeni diziye ekler.
        // lazy : Normalde işlemler sırayla hemen uygulanır. Lazy kullanıldığında ise zincirdeki işlemler birleştirilir yani her bir eleman üzerinde sadece ihtiyaç duyulduğunda işlem yapılır. Gereksiz bellek kullanımını engeller. Büyük dizilerde ve zincirli işlemlerde hızlı
        
        let detections : [Detection] = confidences.lazy.enumerated().filter{$1 > confidenceThreshold}.map { index, confidence in
            let box =  Array(boxes[index * 4..<index * 4 + 4])
            
            let x = CGFloat(box[0])
            let y = CGFloat(box[1])
            let width = CGFloat(box[2] - box[0])
            let height = CGFloat(box[3] - box[1])
            
            let rect = CGRect(x: x, y: y, width: width, height: height)
            
            return Detection(score: confidence, rect: rect)
        }
        
        return detections
    }
    
    
    private func nonMaximumSuppression(predictions: [Detection], iouThreshold: Float = 0.3) -> [Detection] {
        var sorted = predictions.sorted { $0.score > $1.score }
       
        /* Birden fazla insan varsa iou işlemi yapılarak best confidence sahip bounding box ile üst üste gelmeyen bounding boxları listede tutar (farklı insan), üst üste gelen boxları listeden çıkarır (aynı insana ait diğer bounding boxlar).*/
        
        var result : [Detection] = []
         
        while !sorted.isEmpty {
            let best = sorted.removeFirst()
            result.append(best)

            sorted = sorted.filter {
                iou($0.rect, best.rect) < iouThreshold
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
