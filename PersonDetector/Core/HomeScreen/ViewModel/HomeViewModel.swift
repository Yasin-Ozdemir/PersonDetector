//
//  HomeViewModel.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 23.06.2025.
//

import Foundation
import AVFoundation
import TensorFlowLite
import CoreImage

protocol HomeViewModelProtocol {
    func getPhotoOutput() -> AVCapturePhotoOutput?
    func checkCamStatus(status: AVAuthorizationStatus)
    var viewDelegate: HomeViewControllerDelegate? { get set }
    func viewDidLoad()
    func detectPerson(with image: UIImage)
}


final class HomeViewModel: HomeViewModelProtocol {

    weak var viewDelegate: HomeViewControllerDelegate?
    private var personDetector: PersonDetectorProtocol
    private var photoOutput: AVCapturePhotoOutput?
    
    private let yoloInputWidth : CGFloat
    private let yoloInputHeight : CGFloat
    private let yoloConfidenceThreshold : Float

    init(personDetector: PersonDetectorProtocol ,yoloInputWidth: CGFloat, yoloInputHeight: CGFloat, yoloConfidenceThreshold: Float) {
        self.personDetector = personDetector
        self.yoloInputWidth = yoloInputWidth
        self.yoloInputHeight = yoloInputHeight
        self.yoloConfidenceThreshold = yoloConfidenceThreshold
    }


    func viewDidLoad() {
        do {
            try personDetector.setupYolomodel(inputWidth: yoloInputWidth, inputHeight: yoloInputHeight, confidenceThreshold: yoloConfidenceThreshold)
        } catch {
            self.viewDelegate?.showError(title: "error".localized, message: "model_setup_failed".localized)
        }
    }


    func getPhotoOutput() -> AVCapturePhotoOutput? {
        return self.photoOutput
    }


    func checkCamStatus(status: AVAuthorizationStatus) {
        switch status {
        case .authorized: self.setupCamera()
        case .notDetermined: AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? self.setupCamera() : self.viewDelegate?.showPermissionAlert()
                }
            }
        case .denied, .restricted: self.viewDelegate?.showPermissionAlert()
        @unknown default:
            break
        }
    }


    private func setupCamera() {
        let captureSession = AVCaptureSession()
        self.photoOutput = AVCapturePhotoOutput()

        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(input) else {
            self.viewDelegate?.showError(title: "error".localized, message: "camera_input_error".localized)
            return
        }

        captureSession.addInput(input)


        guard captureSession.canAddOutput(photoOutput!) else {
            self.viewDelegate?.showError(title: "error".localized, message: "photo_output_error".localized)
            return
        }
        captureSession.addOutput(photoOutput!)
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill

        viewDelegate?.addPreviewLayer(previewLayer: previewLayer)
    }


    func detectPerson(with image: UIImage) {
        viewDelegate?.showActivityIndicator()
        // task seviyelerine bak High : 0.708 , userInitiated : 0.675, utility : 2.03 , low: 2.05 , medium: 0.71
        Task(priority: .high) {
            do {
                let result = try await personDetector.detectPerson(with: image)
              

                guard let bluredImage = self.blur(image: result.image, rect: result.rect, defaultImageSize: image.size) else {
                    return
                }
                DispatchQueue.main.async {
                    self.viewDelegate?.hideActivityIndicator()
                    self.viewDelegate?.showCustomAlert(image: bluredImage)
                }

            } catch {
                self.viewDelegate?.hideActivityIndicator()
                if error as! PersonDetectorError == PersonDetectorError.detectionFailed {
                    self.viewDelegate?.showError(title: "error".localized, message: "person_detection_failed".localized)
                }
            }

        }

    }


    private func blur(image: UIImage, rect: CGRect, defaultImageSize: CGSize) -> UIImage? {
        guard let resized = image.resize(to: defaultImageSize),
            let ciImage = CIImage(image: resized) else {
            return nil
        }

        let context = CIContext()
        var outputImage = ciImage
       
        let newRect = calculateRect(from: rect, with: defaultImageSize)
       
        let cropped = ciImage.cropped(to: newRect)
        let blurred = cropped
            .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 40])
            .cropped(to: newRect)


        outputImage = blurred.composited(over: outputImage)


        if let finalCG = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: finalCG)
        }

        return nil
    }

    
    private func calculateRect(from rect: CGRect , with imageSize : CGSize) -> CGRect {
        let xRatio = (imageSize.width / self.yoloInputWidth)
        let yRatio = (imageSize.height / self.yoloInputHeight)
        
        let xmin = rect.minX * xRatio
        let ymin = rect.minY  * yRatio
        let xmax = rect.maxX * xRatio
        let ymax = rect.maxY  * yRatio

        return CGRect(x: xmin, y: ymin, width: xmax - xmin, height: ymax - ymin)
    }


}



