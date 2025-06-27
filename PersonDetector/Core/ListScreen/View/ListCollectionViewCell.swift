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
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private let dateLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01.01.01"
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
            
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.dateLabel.topAnchor, constant: -5)
            
        ])
    }
    
    func configureCell(personDetect: Bool , image: UIImage, date: String){
        self.personDetect = personDetect
        self.imageView.image = image
        self.dateLabel.text = date
    }
    
}
