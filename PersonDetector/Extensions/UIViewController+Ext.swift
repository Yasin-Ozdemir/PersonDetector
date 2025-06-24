//
//  UIViewController+Ext.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 23.06.2025.
//

import Foundation
import UIKit

fileprivate var containerView : UIView?
extension UIViewController{
    func showDefaultError(title: String , message : String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func showActivityProgressIndicator(){
        containerView = UIView(frame: self.view.bounds)
        self.view.addSubview(containerView!)
        
        containerView!.backgroundColor = .systemBackground
       
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .blue
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        DispatchQueue.main.async {
            containerView!.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: containerView!.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: containerView!.centerYAnchor),
            ])
            activityIndicator.startAnimating()
        }
        
    }
    
    
    func dismissActivityProgressIndicator(){
            DispatchQueue.main.async {
                
                containerView?.removeFromSuperview()
                containerView = nil
            }
        
       
    }
}
