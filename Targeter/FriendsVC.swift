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
    let imageCache = (UIApplication.shared.delegate as! AppDelegate).imageCache


    
    //MARK: - Outlets
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.register(UINib(nibName: "NewTargetCell", bundle: nil), forCellReuseIdentifier: "NewTargetCell")
        // Set up Navigation controller
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
     /*   if let userID = userID {
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
        }*/
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UITableViewCell
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}
