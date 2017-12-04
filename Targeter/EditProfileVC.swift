//
//  EditProfileVC.swift
//  Targeter
//
//  Created by mac on 11/30/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuthUI

class EditProfileViewController: UIViewController {
    
    // MARK: Properties
    var userID = Auth.auth().currentUser?.uid
    var ref:DatabaseReference!
    // MARK: Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    
    // MARK: - LifeCicle
    override func viewDidLoad() {
        configDatabase()
    }
    
    // MARK: - Delegates
    // MARK: TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    // Firebase functions
    func configDatabase(){
        ref = Database.database().reference()
        if let userID = userID {
            ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let name = value?["name"] as? String ?? ""
                self.nameTextField.text = name
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    // MARK: Assist functions
    

    // MARK: Actions
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func changeImageButton(_ sender: Any) {
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if let userID = userID {
            var userData:[String:String] = [:]
            userData[Constants.UserData.name] = nameTextField.text ?? ""
            userData[Constants.UserData.age] = ageTextField.text ?? ""
            userData[Constants.UserData.city] = cityTextField.text ?? ""
            userData[Constants.UserData.about] = aboutTextField.text ?? ""

            ref.child("users").child(userID).setValue(userData)
            self.dismiss(animated: true, completion: nil)
        }
    }
}