//
//  ListViewModel.swift
//  PersonDetector
//
//  Created by Yasin Özdemir on 26.06.2025.
//


import Foundation
import UIKit

protocol ListViewModelProtocol {
    func numberOfItems() -> Int
    func viewDidLoad()
    func getListModel(at index: Int) -> ListModel?
    func didSelectItem(at index: Int)
    func deleteListModel(at index: Int)
    func filterListModels()
    func fetchListModelsPagination()
    var viewDelegate: ListViewControllerDelegate? { get set }
}

class ListViewModel: ListViewModelProtocol {
   
    private var isFiltered : Bool = false
    private var listModels: [ListModel] = []
    private var listModelsTemp: [ListModel] = []
    private var moreData : Bool = true
    private var lastDate : Date?
    
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
        fetchListModelsPagination()
         addNotificationObserver()
        
    }
    
  
     func fetchListModelsPagination() {
         let startTime = Date()
         guard moreData , !isFiltered else { return }
         
        viewDelegate?.showLoadingIndicator()
         do {
            let objects = try databaseManager.getObjects(model: ListModel.self, lastDate: lastDate, pageSize: 20)
             
             guard !objects.isEmpty else {
                 moreData.toggle()
                 self.viewDelegate?.hideLoadingIndicator()
                 return
             }
             
             self.lastDate = objects.last?.date
             self.listModels.append(contentsOf: objects)
             self.viewDelegate?.updateCollectionView()
             self.viewDelegate?.hideLoadingIndicator()
             let endTime = Date()
             print("Görünme Süresi: \(endTime.timeIntervalSince(startTime)) saniye")
         }catch{
             self.viewDelegate?.hideLoadingIndicator()
             viewDelegate?.showError(title: "error".localized, message: "realm_error".localized)
         }
    }


    private func addNotificationObserver() {
        // extension NSNotification.Name
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .photoSaved, object: nil)
    }


    @objc func reloadData() {
        self.viewDelegate?.scrollToTopCollectionView()
        self.lastDate = nil
        self.moreData = true
        self.listModels = []
        self.fetchListModelsPagination()
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
