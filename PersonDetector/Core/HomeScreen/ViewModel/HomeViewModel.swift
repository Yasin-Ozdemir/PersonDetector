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

    init(personDetector: PersonDetectorProtocol) {
        self.personDetector = personDetector
    }


    func viewDidLoad() {
        do {
            try personDetector.setupYolomodel()
        } catch {
            self.viewDelegate?.showError(title: "ERROR!", message: "Model Setup Failed")
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
            self.viewDelegate?.showError(title: "ERROR!", message: "Camera Input Error.")
            return
        }

        captureSession.addInput(input)


        guard captureSession.canAddOutput(photoOutput!) else {
            self.viewDelegate?.showError(title: "ERROR!", message: "Photo Output Could Not Be Added.")
            return
        }
        captureSession.addOutput(photoOutput!)
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill

        viewDelegate?.addPreviewLayer(previewLayer: previewLayer)
    }


    func detectPerson(with image: UIImage) {
        print(image.size)
        viewDelegate?.showActivityIndicator()
        // task seviyelerine bak High : 0.708 , userInitiated : 0.675, utility : 2.03 , low: 2.05 , medium: 0.71
        Task(priority: .high) {
            do {
                let result = try await personDetector.detectPerson(with: image)

                guard let bluredImage = self.blur(image: result.image, box: result.boxes) else {
                    return
                }
                DispatchQueue.main.async {
                    self.viewDelegate?.hideActivityIndicator()
                    self.viewDelegate?.showCustomAlert(image: bluredImage)
                }

            } catch {
                self.viewDelegate?.hideActivityIndicator()
                if error as! PersonDetectorError == PersonDetectorError.detectionFailed {
                    self.viewDelegate?.showError(title: "ERROR", message: "Person Detection Failed")
                }
            }

        }

    }


   private func blur(image: UIImage, box: [Float]) -> UIImage? {
        guard let resized = image.resize(to: CGSize(width: 3024.0, height: 4032.0)),
            let ciImage = CIImage(image: resized) else {
            return nil
        }

        let context = CIContext()
        var outputImage = ciImage

        let rect = self.calculateRect(from: box)

        let cropped = ciImage.cropped(to: rect)
        let blurred = cropped
            .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 40])
            .cropped(to: rect)


        outputImage = blurred.composited(over: outputImage)


        if let finalCG = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: finalCG)
        }

        return nil
    }


    /* private func blurWithMask(image: UIImage, boxes: [[Float]]) -> UIImage? {
        guard let resized = image.resize(to: CGSize(width: 3024.0, height: 4032.0)),
              let ciImage = CIImage(image: resized) else {
            return nil
        }
        
        let context = CIContext()
        var outputImage = ciImage
               
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(40, forKey: kCIInputRadiusKey)
        
        guard let blurredImage = blurFilter.outputImage else { return nil }
        
        var maskImage: CIImage?
        
        for box in boxes {
            let rect = calculateRect(from: box)
            let rectMask = CIImage(color: CIColor.white).cropped(to: rect)
            
            if maskImage == nil {
                maskImage = rectMask
            } else {
                maskImage = rectMask.composited(over: maskImage!)
            }
        }
        
        guard let finalMask = maskImage else { return nil }
        
        let blendFilter = CIFilter(name: "CIBlendWithMask")!
        blendFilter.setValue(blurredImage, forKey: kCIInputImageKey)
        blendFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(finalMask, forKey: kCIInputMaskImageKey)
        
        guard let result = blendFilter.outputImage,
              let finalCG = context.createCGImage(result, from: result.extent) else {
            return nil
        }
        
        return UIImage(cgImage: finalCG)
    }*/

    private func calculateRect(from box: [Float]) -> CGRect {
        let ymin = CGFloat(box[0]) * 6.3
        let xmin = CGFloat(box[1]) * 4.725
        let ymax = CGFloat(box[2]) * 6.3
        let xmax = CGFloat(box[3]) * 4.725

        return CGRect(x: xmin, y: ymin, width: xmax - xmin, height: ymax - ymin)
    }


}



