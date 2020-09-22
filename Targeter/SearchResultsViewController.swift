//
//  SearchResultsViewController.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/20/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var searchBar = UISearchBar()
    //var users: [UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController(largeTitleDisplayMode: .always)

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

extension SearchResultsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
    
}


extension SearchResultsViewController:  UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 //users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let user = users[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! PeopleCell
//        cell.user = user
//        cell.delegate = self
//
        return UITableViewCell()
    }
}
