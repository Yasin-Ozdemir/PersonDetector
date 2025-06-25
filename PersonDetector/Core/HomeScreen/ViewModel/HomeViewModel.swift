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
    private var personDetector : PersonDetectorProtocol
    private var photoOutput: AVCapturePhotoOutput?
    
    init(personDetector: PersonDetectorProtocol) {
        self.personDetector = personDetector
    }
    
    
    func viewDidLoad() {
        do {
            try personDetector.setupYolomodel()
        }catch{
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
        viewDelegate?.showActivityIndicator()
        Task{
            do {
                _ = try await personDetector.detectPerson(with: image)
                // BLUR İŞLEMİ
                self.viewDelegate?.hideActivityIndicator()
                DispatchQueue.main.async {
                    self.viewDelegate?.showCustomAlert(image: image)
                }
            }catch{
                self.viewDelegate?.hideActivityIndicator()
                if error as! PersonDetectorError == PersonDetectorError.detectionFailed{
                    self.viewDelegate?.showError(title: "ERROR", message: "Person Detection Failed")
                }
            }
            
        }
    
    }
    
}



