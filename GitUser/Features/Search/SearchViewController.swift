//
//  SearchViewController.swift
//  GitUser
//
//  Created by Bing Bing on 2024/7/30.
//

import UIKit
import Combine
import ComposableArchitecture
import GitLibrary

final class SearchViewController: ViewController {
    
    lazy var store: StoreOf<SearchStore> = Store(initialState: SearchStore.State()) { SearchStore() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupSearchResultController()
        bindingStore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Home"
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func bindingStore() {
        store.publisher.isSearching
            .sink { isSearching in
                
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    private func setupSearchResultController() {
        let resultController = SearchResultController()
        addChild(resultController)
        
        view.addSubview(resultController.view)
        resultController.view.translatesAutoresizingMaskIntoConstraints = false
        resultController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        resultController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        resultController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        resultController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        didMove(toParent: self)
        
        searchResultViewController = resultController
    }
    
    // MARK: - Private Properties
    private weak var searchResultViewController: SearchResultController?
    
    private var cancellables: [AnyCancellable] = []
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        store.send(.searchQueryChanged(searchBar.text ?? ""), animation: .default)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        store.send(.searchDidEnd)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        store.send(.searchDidBegin)
    }
}
