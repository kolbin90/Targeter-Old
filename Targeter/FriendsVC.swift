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
        tableView.register(UINib(nibName: "NewTargetCell", bundle: nil), forCellReuseIdentifier: "NewTargetCell")
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
        //let newCell = Bundle.main.loadNibNamed("NewTargetCell", owner: nil, options: nil)!.first as! NewTargetCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewTargetCell") as! NewTargetCell
        
        let targetSnapshot = targets[indexPath.row]
        let target = targetSnapshot.value as! [String:String]
        let title = target[Constants.Target.Title] ?? "Опусти водный бро"
        if let imageURL = target[Constants.Target.ImageURL] as? String {
            if let cachedImage = self.imageCache.object(forKey: "targetImage\(indexPath.row)" as NSString) {
                DispatchQueue.main.async {
                    cell.targetImageView.image = cachedImage
                }
            } else {
                Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX, completion: { (data, error) in
                    guard error == nil else {
                        print("Error downloading: \(error!)")
                        return
                    }
                    if let userImage = UIImage.init(data: data!, scale: 50) {
                        self.imageCache.setObject(userImage, forKey: "targetImage\(indexPath.row)" as NSString)
                        DispatchQueue.main.async {
                            cell.targetImageView.image = userImage
                        }
                    }
                })
            }
        }
        cell.titleLabel.text = title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targets.count
        
    }
    
}
