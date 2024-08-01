//
//  SearchViewController.swift
//  GitUser
//
//  Created by Bing Bing on 2024/7/30.
//

import UIKit
import ComposableArchitecture
import GitLibrary
import GitModel

final class SearchViewController: ViewController {
    
    lazy var store: StoreOf<SearchStore> = Store(initialState: SearchStore.State()) { SearchStore() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        let searchResultViewController = SearchResultController()
        addChild(searchResultViewController)
        
        view.addSubview(searchResultViewController.view)
        searchResultViewController.view.translatesAutoresizingMaskIntoConstraints = false
        searchResultViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchResultViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        searchResultViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        searchResultViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        searchResultViewController.delegate = self
        
        didMove(toParent: self)
        
        var userDetailUserController: UserDetailViewController?
        
        observe { [weak self] in
            guard let self else { return }
            
            self.navigationItem.title = "Home"
            self.navigationController?.navigationBar.prefersLargeTitles = true
            
            searchResultViewController.populate(users: self.store.users, animated: true)
            
            if let store = store.scope(state: \.selectedUser, action: \.showUser.presented), userDetailUserController == nil {
                userDetailUserController = UserDetailViewController(store: store)
                self.navigationController?.pushViewController(userDetailUserController!, animated: true)
            } else if store.selectedUser == nil, userDetailUserController != nil {
                self.navigationController?.popViewController(animated: true)
                userDetailUserController = nil
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isMovingToParent && store.selectedUser != nil {
            store.send(.showUser(.dismiss))
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        store.send(.view(.searchQueryChanged(searchText)))
    }
}

// MARK: - Delegate
extension SearchViewController: SearchResultControllerDelegate {
    
    func didUserLinkTapped(_ link: String) {
        let web = WebViewController()
        web.urlString = link
        self.sheet(web)
    }
    
    func didSearchResultScrollToBottom() {
        store.send(.view(.didScrollViewScrollToBottom))
    }
    
    func didUserRowTapped(user: GitUser) {
        store.send(.view(.didUserRowTapped(user)))
    }
}
