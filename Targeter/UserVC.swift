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

    
    // MARK: Config firebase
    func configDatabase(){
        databaseRef = Database.database().reference()
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
                let city = value?[Constants.UserData.City] as? String ?? ""
                let age = value?[Constants.UserData.Age] as? String ?? ""
                self.cityAgeLabel.text = "\(city), \(age)"
                self.cityAgeLabel.sizeToFit()
                self.aboutLabel.text = value?[Constants.UserData.About] as? String ?? ""
                self.title = value?[Constants.UserData.Username] as? String ?? userID
                self.aboutLabel.sizeToFit()
                if let imageURL = value?[Constants.UserData.ImageURL] as? String {
                    /*
                    DispatchQueue.main.async {
                        let fetchRequest:NSFetchRequest<TargetImages> = TargetImages.fetchRequest()
                        let sortDescriptor = NSSortDescriptor(key: "targetID", ascending: false)
                        let predicate = NSPredicate(format:"targetID = %@", targetID)
                        fetchRequest.sortDescriptors = [sortDescriptor]
                        fetchRequest.predicate = predicate
                        
                        if let result = try? self.stack.context.fetch(fetchRequest) {
                            if result.count > 0 {
                                let targetImages = result[0]
                                if targetImages.imageURL == imageURL {
                                    cell.targetImageView.image = UIImage(data: targetImages.cellImage)
                                } else {
                                    Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX, completion: { (data, error) in
                                        guard error == nil else {
                                            print("Error downloading: \(error!)")
                                            return
                                        }
                                        
                                        if let userImage = UIImage.init(data: data!) {
                                            DispatchQueue.main.async {
                                                let cellImage = self.prepareCellImage(image: userImage)
                                                self.stack.context.delete(targetImages)
                                                _ = TargetImages(targetID: targetID, cellImage: cellImage, fullImage: data!, imageURL: imageURL, context: self.stack.context)
                                                cell.targetImageView.image = userImage
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
                                            let cellImage = self.prepareCellImage(image: userImage)
                                            _ = TargetImages(targetID: targetID, cellImage: cellImage, fullImage: data!, imageURL: imageURL, context: self.stack.context)
                                            cell.targetImageView.image = userImage
                                            self.stack.save()
                                        }
                                    }
                                })
                            }
                        }
                        
                    }
                    */
                    /*
                    if let cachedImage = self.imageCache.object(forKey: "profileImage") {
                        DispatchQueue.main.async {
                            self.userImage.image = cachedImage
                        }
                    } else {
                        Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX, completion: { (data, error) in
                            guard error == nil else {
                                print("Error downloading: \(error!)")
                                return
                            }
                            if let userImage = UIImage.init(data: data!, scale: 50) {
                                self.imageCache.setObject(userImage, forKey: "profileImage")
                                DispatchQueue.main.async {
                                    self.userImage.image = userImage
                                }
                            }
                        })
                    }
                    */
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
            // Trying to sign out from Firebase
            try Auth.auth().signOut()
            _ = navigationController?.popViewController(animated: true)
        } catch {
            print("unable to sign out: \(error)")
        }
        
    }
}
