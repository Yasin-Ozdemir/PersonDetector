//
//  GenericCollectionView.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 26.06.2025.
//


import Foundation
import UIKit

final class GenericCollectionView<Cell : UICollectionViewCell> : UICollectionView, UICollectionViewDelegate , UICollectionViewDataSource{
   
    private var config : ((Int , Cell) -> Void)
    private var numberOfItem : Int
    private var selectionHandler : ((Int)-> Void)
    private var cellID : String
    private var layout : UICollectionViewFlowLayout
    
    init(config: @escaping (Int, Cell) -> Void, numberOfItem: Int, selectionHandler: @escaping (Int) -> Void, cellID: String, layout: UICollectionViewFlowLayout) {
        
        self.config = config
        self.numberOfItem = numberOfItem
        self.selectionHandler = selectionHandler
        self.cellID = cellID
        self.layout = layout
        super.init(frame: .zero, collectionViewLayout: layout)
        
        self.delegate = self
        self.dataSource = self
        self.register(Cell.self, forCellWithReuseIdentifier: self.cellID)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItem
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? Cell else {
            return UICollectionViewCell()
        }
        
        self.config(indexPath.item, cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionHandler(indexPath.item)
    }
    
    func reload(numberOfItem : Int) {
        DispatchQueue.main.async {
            self.numberOfItem = numberOfItem
            self.reloadData()
        }
    }
}
