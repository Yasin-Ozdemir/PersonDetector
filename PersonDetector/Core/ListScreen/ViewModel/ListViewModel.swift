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
    var viewDelegate: ListViewControllerDelegate? { get set }
}


class ListViewModel: ListViewModelProtocol {
    private let databaseManager: DatabaseManagerProtocol

    private var listModels: [ListModel] = []
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
        Task{
            do {
                let id = listModels[index]._id
                try await databaseManager.delete(self.listModels[index], id: id)
                listModels.remove(at: index)
                viewDelegate?.updateCollectionView()
            } catch {
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
        Task(priority: .userInitiated) {
            do {
                let listModels : [ListModel] = try await databaseManager.getAll(model: ListModel.self)
                
                self.listModels = listModels
                self.viewDelegate?.updateCollectionView()
                self.viewDelegate?.hideLoadingIndicator()
                
            } catch {
                self.viewDelegate?.hideLoadingIndicator()
                viewDelegate?.showError(title: "error".localized, message: "realm_error".localized)
            }
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


}
