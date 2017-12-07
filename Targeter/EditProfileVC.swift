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

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        hideKeyboardWhenTappedAround()
        configDatabase()
    }
    
    // MARK: - Delegates
    
    // Firebase functions
    func configDatabase(){
        ref = Database.database().reference()
        if let userID = userID {
            ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                self.nameTextField.text = value?[Constants.UserData.name] as? String ?? ""
                self.ageTextField.text = value?[Constants.UserData.age] as? String ?? ""
                self.cityTextField.text = value?[Constants.UserData.city] as? String ?? ""
                self.aboutTextField.text = value?[Constants.UserData.about] as? String ?? ""
                //self.nameTextField.text = name
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    // MARK: Assist functions
    //MARK:  ImagePicker
    func imagePicker(_ type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = type
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
        
    }

    // MARK: Actions
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func changeImageButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default) { action in
            self.imagePicker(.photoLibrary)
            
        })
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default){ action in
                self.imagePicker(.camera)
                
            })
        }
        
        actionSheet.addAction(UIAlertAction(title: "Download from Flickr", style: .default) { action in
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ImageFromFlickerVC") as! ImageFromFlickerVC
            self.navigationController?.pushViewController(controller, animated: true)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
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
