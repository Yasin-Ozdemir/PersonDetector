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


    func viewDidLoad() {
        fetchListModels()
        addNotificationObserver()
    }


    func fetchListModels() {
        Task(priority: .userInitiated) {
            do {
                let listModels = try await databaseManager.getAll(model: ListModel.self)
                
                DispatchQueue.main.async {
                    self.listModels = listModels
                    self.viewDelegate?.updateCollectionView()
                }
            } catch {
                viewDelegate?.showError(title: "error".localized, message: "realm_error".localized)
            }
        }

    }


    func addNotificationObserver() {
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
