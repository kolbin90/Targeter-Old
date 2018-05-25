//
//  FriendsVC.swift
//  Targeter
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FriendsViewController: UITableViewController {
    // FriendsViewController is in work and will be updated
    
    //MARK: - Properties
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    var targets:[DataSnapshot]! = []
    fileprivate var _refHandle: DatabaseHandle!
    let imageCache = (UIApplication.shared.delegate as! AppDelegate).imageCache


    
    //MARK: - Outlets
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configDatabase()
        configureStorage()
        downloadTargets()
    }
    deinit {

    }
    // MARK: - Delegates
    
    // MARK: Firebase functions
    func configDatabase(){
        databaseRef = Database.database().reference()
    }
    func configureStorage() {
        storageRef = Storage.storage().reference()
    }
    func downloadTargets() {

    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UITableViewCell
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}
