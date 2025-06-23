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
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        view.addSubviews(imageView)
    }

    private func applyConstraints() {
        NSLayoutConstraint.activate([
            
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.25)
            
            ])
    }
    
    private func checkCam(){
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized: presentCam()
        case .notDetermined :  AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                granted ? self.presentCam() : self.showPermissionAlert()
            }
        }
        case .denied , .restricted: showPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func presentCam(){
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.cameraCaptureMode = .photo
        present(picker,animated: true)
    }
    
    private func showPermissionAlert() {
         let alert = UIAlertController(title: "Camera Permission Required", message: "Please allow camera access in the settings.",preferredStyle: .alert)
        
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
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let image = info[.originalImage] as? UIImage {
               imageView.image = image
           }
           picker.dismiss(animated: true)
       }

       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true)
       }}
