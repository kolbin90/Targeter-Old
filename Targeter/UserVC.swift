//
//  UserVC.swift
//  Targeter
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseUI
import CoreData
import FirebaseAuth
import FBSDKLoginKit


class UserViewController: UIViewController {
    
    // MARK: Properties
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    let imageCache = (UIApplication.shared.delegate as! AppDelegate).imageCache
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var targetsCount:Int?
    fileprivate var _refHandle: DatabaseHandle!

    // Mark: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var cityAgeLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var numFriendsLabel: UILabel!
    @IBOutlet weak var numTargetsLabel: UILabel!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        // Configure Firebase
        configDatabase()
        configureStorage()
        if #available(iOS 11.0, *) {
            // Use large title for newer iOS
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Use regular on older
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        fillUserInformation()
    }
    
    deinit {
        // Remove auth listener
        if let userID = userID {
            databaseRef.child(Constants.RootFolders.Targets).child(userID).removeObserver(withHandle: _refHandle)
        }
    }
    
    
    // MARK: Config firebase
    func configDatabase(){
        databaseRef = Database.database().reference()
        _refHandle = databaseRef.child(Constants.RootFolders.Users).child(self.userID!).observe(.childChanged, with: { (snapshot) in
            self.fillUserInformation()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func configureStorage() {
        storageRef = Storage.storage().reference()
    }
    func fillUserInformation() {
        if let userID = userID {
            // Download user data and fill labels with data
            databaseRef.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let targetsCount = self.targetsCount {
                    self.numTargetsLabel.text = String(targetsCount)
                } else {
                    self.numTargetsLabel.text = "0"

                }
                // Get user value
                let value = snapshot.value as? NSDictionary
                if let name = value?[Constants.UserData.Name] as? String {
                    self.nameLabel.text = " \(name) "
                } else {
                    self.nameLabel.text = ""
                }
                if let city = value?[Constants.UserData.City] as? String, city != "" {
                    if let age = value?[Constants.UserData.Age] as? String, age != "" {
                        self.cityAgeLabel.text = " \(city), \(age) "
                    } else {
                        self.cityAgeLabel.text = " \(city) "
                    }
                } else {
                    if let age = value?[Constants.UserData.Age] as? String, age != "" {
                        self.cityAgeLabel.text = " \(age) "
                    } else {
                        self.cityAgeLabel.alpha = 0
                    }
                }
                //self.cityAgeLabel.text = "\(city), \(age)"
                if let userPercentage = value?[Constants.UserData.Percentage] as? String, userPercentage != "" {
                    self.percentageLabel.text = " \(userPercentage)% "
                } else {
                    self.percentageLabel.text = "0%"
                }
                self.cityAgeLabel.sizeToFit()
                self.aboutLabel.text = value?[Constants.UserData.About] as? String ?? ""
                self.title = value?[Constants.UserData.Username] as? String ?? "userID"
                self.aboutLabel.sizeToFit()
                // Check if we have image URL
                if let imageURL = value?[Constants.UserData.ImageURL] as? String {
                    DispatchQueue.main.async {
                        let fetchRequest:NSFetchRequest<ProfileImage> = ProfileImage.fetchRequest()
                        let sortDescriptor = NSSortDescriptor(key: "userID", ascending: false)
                        let predicate = NSPredicate(format:"userID = %@", userID)
                        fetchRequest.sortDescriptors = [sortDescriptor]
                        fetchRequest.predicate = predicate
                        // Check if we have image in Core Data
                        if let result = try? self.stack.context.fetch(fetchRequest) {
                            if result.count > 0 {
                                let profileImage = result[0]
                                if profileImage.imageURL == imageURL {
                                    // Check if it's the same image that we need, if so use it
                                    self.userImage.image = UIImage(data: profileImage.imageData)
                                } else {
                                    // If its a different one, download a new image from Firebase and replase it in coredata
                                    Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX, completion: { (data, error) in
                                        guard error == nil else {
                                            print("Error downloading: \(error!)")
                                            return
                                        }
                                        
                                        if let userImage = UIImage.init(data: data!) {
                                            DispatchQueue.main.async {
                                                self.stack.context.delete(profileImage)
                                                _ = ProfileImage(userID: userID, imageData: data!, imageURL: imageURL, context: self.stack.context)
                                                self.userImage.image = userImage
                                                self.stack.save()
                                            }
                                        }
                                    })
                                }
                            } else {
                                // If we have nothing in CoreDta we download image from Firebase and save it to core data
                                Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX, completion: { (data, error) in
                                    guard error == nil else {
                                        print("Error downloading: \(error!)")
                                        return
                                    }
                                    
                                    if let userImage = UIImage.init(data: data!) {
                                        DispatchQueue.main.async {
                                            _ = ProfileImage(userID: userID, imageData: data!, imageURL: imageURL, context: self.stack.context)
                                            self.userImage.image = userImage
                                            self.stack.save()
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: Assist functions

    
    // MARK: Actions
    @IBAction func editButton(_ sender: Any) {
    }
    @IBAction func logoutButton(_ sender: Any) {
        do {
            // Delete all data from Core Data, when logged out
            try stack.dropAllData()
        } catch {
            print("Ebat' error")
        }
        do {
            // Trying to sign out from Firebase
            let manager = FBSDKLoginManager()
            manager.logOut()
            try Auth.auth().signOut()
            _ = navigationController?.popViewController(animated: true)
        } catch {
            print("unable to sign out: \(error)")
        }
    }
}
