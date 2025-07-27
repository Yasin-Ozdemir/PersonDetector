//
//  HomeViewController.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 23.06.2025.
//

import UIKit
import AVFoundation

protocol HomeViewControllerDelegate: AnyObject {
    func showError(title: String, message: String)
    func addPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer)
    func showPermissionAlert()
    func showCustomAlert(image: UIImage)
    func showActivityIndicator()
    func hideActivityIndicator()
}


final class HomeViewController: UIViewController {
    private var presentedCam = false

    private var viewModel: HomeViewModelProtocol

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
        button.setTitle("done_button".localized, for: .normal)
        button.backgroundColor = .secondaryLabel
        button.setTitleColor(.secondarySystemBackground, for: .normal)
        button.layer.cornerRadius = 15
        return button
    }()

    private let restartButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("restart_button".localized, for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.layer.cornerRadius = 15
        return button
    }()


    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.viewDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviews()
        applyConstraints()
        viewModel.viewDidLoad()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !presentedCam {
            presentedCam.toggle()
            checkCam()
        }
    }


    private func addSubviews() {
        view.addSubviews(cameraPreviewView, captureButton, settingsButton, doneButton, restartButton)
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
            settingsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            settingsButton.widthAnchor.constraint(equalToConstant: 90),
            settingsButton.heightAnchor.constraint(equalToConstant: 60),

            restartButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            restartButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            restartButton.heightAnchor.constraint(equalToConstant: 40),
            restartButton.widthAnchor.constraint(equalToConstant: 90),
            
            doneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            doneButton.heightAnchor.constraint(equalToConstant: 30),
            doneButton.widthAnchor.constraint(equalToConstant: 60),
            ])
    }


    private func checkCam() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        viewModel.checkCamStatus(status: status)
    }

    
    @objc func tappedCapture() {
        guard let photoOutput = viewModel.getPhotoOutput() else {
            return
        }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}



extension HomeViewController: HomeViewControllerDelegate {
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.showActivityProgressIndicator()
        }
       
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.dismissActivityProgressIndicator()
        }
    }
    
    
    func showCustomAlert(image: UIImage) {
        let customAlert = CustomAlertController(image: image) { [weak self] in
            self?.viewModel.saveImageToDB(image: image, date: Date(), isPersonDetected: true)
        }
        customAlert.modalTransitionStyle = .crossDissolve
        customAlert.modalPresentationStyle = .fullScreen
        self.present(customAlert,animated: true)
    }
    

    func showPermissionAlert() {
        let alert = UIAlertController(title: "camera_permission_title".localized, message: "camera_permission_message".localized, preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "settings".localized, style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }

        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel)

        alert.addAction(settingsAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }


    func addPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer) {
        previewLayer.frame = view.bounds
        cameraPreviewView.layer.addSublayer(previewLayer)

        guard let session = previewLayer.session else {
            return
        }
        
        DispatchQueue.global().async {
            session.startRunning()
        }
    }


    func showError(title: String, message: String) {
        self.showDefaultError(title: title, message: message)
    }
}



extension HomeViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard error == nil else {
            self.showDefaultError(title: "error".localized, message: error!.localizedDescription)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData) else {
            return
        }

        viewModel.detectPerson(with: image)
      
    }
    
    
    
}
