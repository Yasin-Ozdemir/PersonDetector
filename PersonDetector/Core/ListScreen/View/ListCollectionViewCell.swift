//
//  ListCollectionViewCell.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 26.06.2025.
//


import UIKit

final class ListCollectionViewCell: UICollectionViewCell {
    static let cellID = "ListCollectionViewCell"
    private var personDetect : Bool = false
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dateLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10
        showViews()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    
    private func showViews(){
        self.addSubviews(imageView , dateLabel)
    }
    
    private func applyConstraints(){
        NSLayoutConstraint.activate([
            self.dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            self.dateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.dateLabel.topAnchor, constant: -5)
            
        ])
    }
    

    func configureCell(with listModel : ListModel?){
        guard let listModel  = listModel else { return }
        self.personDetect = listModel.isPersonDetected
        self.imageView.image = UIImage(data: listModel.imageData)
        self.dateLabel.text = listModel.date
        
        changeBackgroundColor()
    }
    
    private func changeBackgroundColor(){
        if self.personDetect {
            self.backgroundColor = .systemRed.withAlphaComponent(0.3)
        } else {
            self.backgroundColor = .secondarySystemBackground
        }
    }
    
}
