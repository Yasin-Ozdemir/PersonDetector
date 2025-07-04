//
//  ListViewModel.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 26.06.2025.
//


import Foundation
import UIKit
import RealmSwift

protocol ListViewModelProtocol {
    func numberOfItems() -> Int
    func viewDidLoad()
    func getListModel(at index: Int) -> ListModel?
    func didSelectItem(at index: Int)
    func deleteListModel(at index: Int)
    func filterListModels()
    var viewDelegate: ListViewControllerDelegate? { get set }
}


class ListViewModel: ListViewModelProtocol {
   
    private var isFiltered : Bool = false
    private var listModels: [ListModel] = []
    private var listModelsTemp: [ListModel] = []
    
    private let databaseManager: DatabaseManagerProtocol
    weak var viewDelegate: ListViewControllerDelegate?
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }


    func numberOfItems() -> Int {
        listModels.count
    }


    func didSelectItem(at index: Int) {
        guard listModels[index].isPersonDetected else {
            return
        }
        viewDelegate?.navigateTo(viewController: HomeViewController(viewModel: HomeViewModel(personDetector: PersonDetector(), databaseManager: DatabaseManager())))
    }

    
    func deleteListModel(at index: Int) {
        viewDelegate?.showLoadingIndicator()
        let id = listModels[index]._id
        Task{
            do {
                try await databaseManager.delete(modelType: ListModel.self, id: id)
                listModels.remove(at: index)
                viewDelegate?.updateCollectionView()
                self.viewDelegate?.hideLoadingIndicator()
            } catch {
                self.viewDelegate?.hideLoadingIndicator()
                viewDelegate?.showError(title: "error".localized, message: "realm_error".localized)
            }
           
        }
    }
    
    
    func viewDidLoad() {
        fetchListModels()
        addNotificationObserver()
    }


    private func fetchListModels() {
        viewDelegate?.showLoadingIndicator()
            do {
                let listModels = try databaseManager.getAll(model: ListModel.self)
                
                self.listModels = Array(listModels)
                self.viewDelegate?.updateCollectionView()
                self.viewDelegate?.hideLoadingIndicator()
                
            } catch {
                self.viewDelegate?.hideLoadingIndicator()
                viewDelegate?.showError(title: "error".localized, message: "realm_error".localized)
            }
    }


    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name("PhotoSaved"), object: nil)
    }


    @objc func reloadData() {
        fetchListModels()
    }


    func getListModel(at index: Int) -> ListModel? {
        guard index < listModels.count else { return nil }
        return listModels[index]
    }

    
    func filterListModels(){
        if !isFiltered {
            self.listModelsTemp = listModels
            self.listModels = listModels.filter{$0.isPersonDetected}
            self.viewDelegate?.updateCollectionView()
        }else {
            self.listModels = listModelsTemp
            self.viewDelegate?.updateCollectionView()
        }
        self.isFiltered.toggle()
        
    }
}
