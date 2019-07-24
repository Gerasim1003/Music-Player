//
//  SearchViewController+SearchBarDelegate.swift
//  Music Player
//
//  Created by Gerasim Israyelyan on 7/23/19.
//  Copyright © 2019 Gerasim Israyelyan. All rights reserved.
//

import UIKit

extension SearchViewController: UISearchBarDelegate {
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        queryService.getSearchResults(searchTerm: searchText) { results in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let results = results {
                self.searchResults = results
                self.tableView.reloadData()
                self.tableView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}
