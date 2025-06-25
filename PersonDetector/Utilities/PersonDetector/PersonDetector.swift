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
    func setupYolomodel() throws
    func detectPerson(with image: UIImage) async throws  -> DetectedModel
}

class PersonDetector: PersonDetectorProtocol {
    private var interpreter: Interpreter?

    private let inputWidth = 640
    private let inputHeight = 640
    private let confidenceThreshold: Float = 0.3
    private let maxDetections = 8400


    func setupYolomodel() throws {
        guard let modelPath = Bundle.main.path(forResource: "person-det 1", ofType: "tflite") else {
            print("Model bulunamadı")
            return
        }
        // interpreter options threadlere bak
        var options = Interpreter.Options()
        options.threadCount = 2  // 1 : 0.711 - 2: 0.58 - 3: 0.56 - 4: 0.54
       // options.isXNNPackEnabled = true | high-performance kernel library|  MODEL DESTEKLEMİYOR :(
        interpreter = try Interpreter(modelPath: modelPath , options: options)
        try interpreter?.allocateTensors()
        print("Model başarıyla yüklendi!")

    }


    func detectPerson(with image: UIImage) async throws -> DetectedModel  {
        let startTime = Date()
        guard let inputData = preprocess(image: image), let interpreter = interpreter else {
                throw PersonDetectorError.detectionFailed
            }

           let result = try await withCheckedThrowingContinuation { continuation in
            
                    do {
                        try interpreter.copy(inputData, toInputAt: 0)
                        try interpreter.invoke()

                        let boxes = try interpreter.output(at: 0).data.toArray(type: Float32.self)
                        let confidences = try interpreter.output(at: 1).data.toArray(type: Float32.self)
                        let classes = try interpreter.output(at: 2).data.toArray(type: Float32.self)

                      
                       for (i, cls) in classes.enumerated() {
                            if Int(cls) == 0 && confidences[i] > 0.3 {
                                let box : [Float] = Array(boxes[i * 4..<i * 4 + 4])
                                let detectedModel = DetectedModel(image: setupImage(image)!, boxes: box)
                                continuation.resume(returning: detectedModel)
                                return
                            }
                        }
                        continuation.resume(throwing: PersonDetectorError.noPerson)
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
}
