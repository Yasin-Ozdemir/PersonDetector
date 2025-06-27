//
//  ListViewController.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 26.06.2025.
//


import UIKit

class ListViewController: UIViewController {

    private var viewModel : ListViewModelProtocol
    private var collectionView : GenericCollectionView<ListCollectionViewCell>!
   
    init(viewModel: ListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        applyConstraints()
        view.backgroundColor = .systemBackground
    }
    
    
    private func setupNavigationBar(){
        self.navigationItem.title = "Person Detector App"
        self.navigationController?.navigationBar.tintColor = .label
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    
    private func setupCollectionView(){
       
        collectionView = .init(config: { index, cell in
            // cell.configure methodu
        }, numberOfItem: 15, selectionHandler: { index in
            // viewModel.didSelectItem
        }, cellID: ListCollectionViewCell.cellID, layout: createTwoColumnLayout())
        
        view.addSubview(collectionView)
   
    }
    
    
    private func applyConstraints(){
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    
    private func createTwoColumnLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: (Double(self.view.bounds.width - 40) / 2), height: 250)
        return layout
    }
    
    
    @objc func addButtonTapped(){
        navigationController?.pushViewController(HomeViewController(viewModel: HomeViewModel(personDetector: PersonDetector() , yoloInputWidth: 640 , yoloInputHeight: 640, yoloConfidenceThreshold: 0.3)), animated: true)
    }
}

