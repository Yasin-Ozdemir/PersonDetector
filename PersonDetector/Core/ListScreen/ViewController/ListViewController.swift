//
//  ListViewController.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 26.06.2025.
//


import UIKit

protocol ListViewControllerDelegate : AnyObject {
    func showError(title: String,message: String)
    func updateCollectionView()
    func navigateTo(viewController: UIViewController)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class ListViewController: UIViewController {

    private var viewModel : ListViewModelProtocol
    private var collectionView : GenericCollectionView<ListCollectionViewCell>!
   
    init(viewModel: ListViewModelProtocol) {
        self.viewModel = viewModel
      
        super.init(nibName: nil, bundle: nil)
        self.viewModel.viewDelegate = self
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
        viewModel.viewDidLoad()
    }
    
    
    private func setupNavigationBar(){
        self.navigationItem.title = "Person Detector App"
        self.navigationController?.navigationBar.tintColor = .label
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    
    private func setupCollectionView(){
       
        collectionView = .init(config: { [weak self ]index, cell in
            let listModel =  self?.viewModel.getListModel(at: index)
            cell.configureCell(with: listModel)
            
        }, numberOfItem: viewModel.numberOfItems(), selectionHandler: {[weak self] index in
            self?.viewModel.didSelectItem(at: index)
        }, cellID: ListCollectionViewCell.cellID, layout: createTwoColumnLayout(), deletionHandler: { index in
            self.viewModel.deleteListModel(at: index)
        })
        
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
        self.navigateTo(viewController: HomeViewController(viewModel: HomeViewModel(personDetector: PersonDetector(), databaseManager: DatabaseManager())))
    }
    
    
}

extension ListViewController : ListViewControllerDelegate {
    func showLoadingIndicator() {
        showActivityProgressIndicator()
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.dismissActivityProgressIndicator()
        }
    }
    
    func navigateTo(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showError(title: String, message: String) {
        self.showDefaultError(title: title, message: message)
    }
    
    func updateCollectionView() {
        self.collectionView.reload(numberOfItem: self.viewModel.numberOfItems())
    }
    
    
}
