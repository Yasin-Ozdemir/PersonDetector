//
//  HomeViewModel.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 23.06.2025.
//

import Foundation
import AVFoundation

protocol HomeViewModelProtocol{
    func getPhotoOutput() -> AVCapturePhotoOutput?
    func checkCamStatus(status : AVAuthorizationStatus)
    var viewDelegate : HomeViewControllerDelegate? { get set }
}


final class HomeViewModel: HomeViewModelProtocol{
    weak var viewDelegate : HomeViewControllerDelegate?
    
  
    private var photoOutput: AVCapturePhotoOutput?
  
    func getPhotoOutput() -> AVCapturePhotoOutput?{
        return self.photoOutput
    }
    
    
    func checkCamStatus(status : AVAuthorizationStatus){
        switch status {
        case .authorized: self.setupCaptureSession()
        case .notDetermined: AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? self.setupCaptureSession() : self.viewDelegate?.showPermissionAlert()
                }
            }
        case .denied, .restricted: self.viewDelegate?.showPermissionAlert()
        @unknown default:
            break
        }
    }
    
    
    private func setupCaptureSession(){
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
       let  previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        viewDelegate?.addPreviewLayer(previewLayer: previewLayer)
    }
    
  
}
