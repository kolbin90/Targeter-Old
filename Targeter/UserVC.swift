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

class UserViewController: UIViewController {
    
    // MARK: Properties
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!

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
        fillUserInformation()
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
                self.nameLabel.text = value?[Constants.UserData.name] as? String ?? ""
                let city = value?[Constants.UserData.city] as? String ?? ""
                let age = value?[Constants.UserData.age] as? String ?? ""
                self.cityAgeLabel.text = "\(city), \(age)"
                self.cityAgeLabel.sizeToFit()
                self.aboutLabel.text = value?[Constants.UserData.about] as? String ?? ""
                self.aboutLabel.sizeToFit()
                if let imageURL = value?[Constants.UserData.imageURL] as? String {
                    Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX, completion: { (data, error) in
                        guard error == nil else {
                            print("Error downloading: \(error!)")
                            return
                        }
                        let userImage = UIImage.init(data: data!, scale: 50)
                        DispatchQueue.main.async {
                            self.userImage.image = userImage
                        }
                    })
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
