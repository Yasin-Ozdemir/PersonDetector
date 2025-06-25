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
    func detectPerson(with image: UIImage) async throws -> [[Float]]
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

        interpreter = try Interpreter(modelPath: modelPath)
        try interpreter?.allocateTensors()
        print("Model başarıyla yüklendi!")

    }


    func detectPerson(with image: UIImage) async throws -> [[Float]]  {
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

                        var detectedBoxes = [[Float]]()
                       for (i, cls) in classes.enumerated() {
                            if Int(cls) == 0 && confidences[i] > 0.3 {
                                let box = Array(boxes[i * 4..<i * 4 + 4])
                                detectedBoxes.append(box)
                                continuation.resume(returning: detectedBoxes)
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
        guard let resizedImage = image.resize(to: CGSize(width: 640, height: 640)) else {
            print("Resim yeniden boyutlandırılamadı.")
            return nil
        }

        guard let rgbData = resizedImage.rgbData() else {
            print("RGB verisi oluşturulamadı.")
            return nil
        }

        return rgbData
    }
}
