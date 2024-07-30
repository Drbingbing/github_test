//
//  SearchViewController.swift
//  GitUser
//
//  Created by Bing Bing on 2024/7/30.
//

import UIKit

final class SearchViewController: ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupSearchResultController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Home"
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
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
}
