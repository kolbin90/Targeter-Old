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
    
    //MARK: - Properties
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    var targets:[DataSnapshot]! = []
    fileprivate var _refHandle: DatabaseHandle!

    
    //MARK: - Outlets
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up Navigation controller
        configDatabase()
        configureStorage()
        downloadTargets()
    }
    deinit {
        // TODO: set up what needs to be deinitialized when view is no longer being used
        if let userID = userID {
            databaseRef.child(Constants.RootFolders.Targets).child(userID).removeObserver(withHandle: _refHandle)
        }
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
        if let userID = userID {
            _refHandle = databaseRef.child(Constants.RootFolders.Targets).child(userID).observe(.childAdded, with: { (snapshot) in
                self.targets.append(snapshot)
                let value = snapshot.value as? [String:AnyObject]
                self.tableView.reloadData()
                //print(value?.allValues[0])
                //let targetValue
               // print(Array(value!.values)[0])
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: UITableViewControllerDelegate & DataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "NewTargetCell", for: indexPath) as! NewTargetCell
        let newCell = Bundle.main.loadNibNamed("NewTargetCell", owner: nil, options: nil)!.first as! NewTargetCell
        return newCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targets.count
        
    }
    
}
