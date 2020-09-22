//
//  SearchResultViewController.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/22/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black

        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.frame.size.width = view.frame.size.width - 60
        searchBar.delegate = self
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        navigationItem.rightBarButtonItem = searchItem
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        tableView.dataSource = self
        
        doSearch()
    }
    
    
    
    @objc func hideKeyboard() {
        searchBar.endEditing(true)
    }
    
    func doSearch() {
//        if let searchText = searchBar.text?.lowercased() {
//            users.removeAll()
//            tableView.reloadData()
//            Api.user.queryUsers(withText: searchText) { (user) in
//                if !self.users.contains(where: { $0.id == user.id }) {
//                    self.isFollowing(withUserId: user.id!, completed: { (value) in
//                        user.isFollowing = value
//                        self.users.append(user)
//                        self.tableView.reloadData()
//                    })
//                }
//
//            }
//        }
    }
    
}

extension SearchResultViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        doSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        doSearch()
    }
    
}

extension SearchResultViewController:  UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 //users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! UITableViewCell
//        cell.user = user
//        cell.delegate = self
//
        return cell
    }
}
