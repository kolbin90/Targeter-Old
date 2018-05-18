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
import FirebaseAuthUI
import CoreData

class UserViewController: UIViewController {
    
    // MARK: Properties
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    let imageCache = (UIApplication.shared.delegate as! AppDelegate).imageCache
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack

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
        //fillUserInformation()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
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
            databaseRef.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                self.nameLabel.text = value?[Constants.UserData.Name] as? String ?? ""
                //let city = value?[Constants.UserData.City] as? String ?? ""
                //let age = value?[Constants.UserData.Age] as? String ?? ""
                if let city = value?[Constants.UserData.City] as? String, city != "" {
                    if let age = value?[Constants.UserData.Age] as? String, age != "" {
                        self.cityAgeLabel.text = "\(city), \(age)"
                    } else {
                        self.cityAgeLabel.text = "\(city)"
                    }
                } else {
                    if let age = value?[Constants.UserData.Age] as? String, age != "" {
                        self.cityAgeLabel.text = "\(age)"
                    } else {
                        self.cityAgeLabel.alpha = 0
                    }
                }
                //self.cityAgeLabel.text = "\(city), \(age)"
                if let userPercentage = value?[Constants.UserData.Percentage] as? String, userPercentage != "" {
                    self.percentageLabel.text = "\(userPercentage)%"
                } else {
                    self.percentageLabel.text = "0%"
                }
                //self.percentageLabel.text = "\((value?[Constants.UserData.Percentage] as? String))%" ?? "0%"
                self.cityAgeLabel.sizeToFit()
                self.aboutLabel.text = value?[Constants.UserData.About] as? String ?? ""
                self.title = value?[Constants.UserData.Username] as? String ?? "userID"
                self.aboutLabel.sizeToFit()
                if let imageURL = value?[Constants.UserData.ImageURL] as? String {
                    
                    DispatchQueue.main.async {
                        let fetchRequest:NSFetchRequest<ProfileImage> = ProfileImage.fetchRequest()
                        let sortDescriptor = NSSortDescriptor(key: "userID", ascending: false)
                        let predicate = NSPredicate(format:"userID = %@", userID)
                        fetchRequest.sortDescriptors = [sortDescriptor]
                        fetchRequest.predicate = predicate
                        
                        if let result = try? self.stack.context.fetch(fetchRequest) {
                            if result.count > 0 {
                                let profileImage = result[0]
                                if profileImage.imageURL == imageURL {
                                    self.userImage.image = UIImage(data: profileImage.imageData)
                                } else {
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
    func configUI() {
    }
    
    // MARK: Actions
    @IBAction func editButton(_ sender: Any) {
    }
    @IBAction func logoutButton(_ sender: Any) {
        do {
            try stack.dropAllData()
        } catch {
            print("Ebat' error")
        }
        do {
            // Trying to sign out from Firebase
            try Auth.auth().signOut()
            _ = navigationController?.popViewController(animated: true)
        } catch {
            print("unable to sign out: \(error)")
        }
    }
}
