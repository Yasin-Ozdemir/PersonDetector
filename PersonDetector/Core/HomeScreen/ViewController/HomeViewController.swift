//
//  HomeViewController.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 23.06.2025.
//

import UIKit
import AVFoundation
import TensorFlowLite
final class HomeViewController: UIViewController {
    private var presentedCam = false
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!


    private let cameraPreviewView = UIView()

    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(tappedCapture), for: .touchUpInside)
        return button
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        button.imageView?.contentMode = .scaleToFill
        button.tintColor = .label
        return button
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.backgroundColor = .secondaryLabel
        button.setTitleColor(.secondarySystemBackground, for: .normal)
        button.layer.cornerRadius = 15
        return button
    }()
    
    private let restartButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Restart", for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.layer.cornerRadius = 15
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviews()
        applyConstraints()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !presentedCam {
            presentedCam.toggle()
            checkCam()
        }
    }

    
    private func addSubviews() {
        view.addSubviews(cameraPreviewView, captureButton, settingsButton, doneButton , restartButton)
    }

    
    private func applyConstraints() {
        cameraPreviewView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cameraPreviewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cameraPreviewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cameraPreviewView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cameraPreviewView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 60),
            captureButton.heightAnchor.constraint(equalToConstant: 60),
            
            settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            settingsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            settingsButton.widthAnchor.constraint(equalToConstant: 60),
            settingsButton.heightAnchor.constraint(equalToConstant: 60),
            
            restartButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            restartButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            restartButton.heightAnchor.constraint(equalToConstant: 30),
            restartButton.widthAnchor.constraint(equalToConstant: 60),
            
            doneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            doneButton.heightAnchor.constraint(equalToConstant: 30),
            doneButton.widthAnchor.constraint(equalToConstant: 60),
            ])
    }

    
    private func checkCam() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized: self.setupCam()
        case .notDetermined: AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? self.setupCam() : self.showPermissionAlert()
                }
            }
        case .denied, .restricted: showPermissionAlert()
        @unknown default:
            break
        }
    }
    
    
    private func setupCam() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(input) else {
            showDefaultError(title: "ERROR!", message: "Camera Input Error.")
            return
        }

        captureSession.addInput(input)

        photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else {
            showDefaultError(title: "ERROR!", message: "Photo Output Could Not Be Added.")
            return
        }
        captureSession.addOutput(photoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        cameraPreviewView.layer.addSublayer(previewLayer)

        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }

    }
    
    
    private func showPermissionAlert() {
        let alert = UIAlertController(title: "Camera Permission Required", message: "Please allow camera access in the settings.", preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(settingsAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    
    @objc func tappedCapture() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}



extension HomeViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,didFinishProcessingPhoto photo: AVCapturePhoto,error: Error?) {

        guard let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData) else {
            return
        }

        let customAlertController = CustomAlertController(image: image)
        customAlertController.modalPresentationStyle = .overFullScreen
        customAlertController.modalTransitionStyle = .crossDissolve
        present(customAlertController, animated: true)
    }
}
