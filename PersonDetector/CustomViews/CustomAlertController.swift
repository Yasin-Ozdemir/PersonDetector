//
//  CustomAlertController.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 23.06.2025.
//

import Foundation
import UIKit
final class CustomAlertController : UIViewController{
    private let alertTitle = "Person has been detected."
    private let alertBody = "If you keep this image, information will be logged in your visit."
    
    private let container : UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let titleLabel : UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bodyLabel : UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageView : UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private let removeButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Remove Image", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return button
    }()
    
    private let keepButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Keep Image", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return button
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(image : UIImage) {
        self.init(nibName: nil, bundle: nil)
        self.imageView.image = image
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        addSubViews()
        applyConstraints()
        titleLabel.text = alertTitle
        bodyLabel.text = alertBody
    }
    
    private  func addSubViews(){
        view.addSubview(container)
        container.addSubviews(titleLabel , bodyLabel, imageView , removeButton , keepButton)
    }
    
    private func applyConstraints(){
        NSLayoutConstraint.activate([
            
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            container.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.8),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor , constant: 10),
            
            bodyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            bodyLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
            
            imageView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 15),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.9),
            imageView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.65),
            
            removeButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            removeButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            removeButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.4),
            removeButton.heightAnchor.constraint(equalToConstant: 30),
            
            keepButton.topAnchor.constraint(equalTo: removeButton.bottomAnchor, constant: 10),
            keepButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            keepButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.4),
            keepButton.heightAnchor.constraint(equalToConstant: 30)
            
        ])
    }
    
    @objc private func dismissAlert(){
        self.dismiss(animated: true)
    }
}

