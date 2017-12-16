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
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    var profileImageChanged = false
    var newProfileImage: UIImage? = nil
    let imageCache = (UIApplication.shared.delegate as! AppDelegate).imageCache

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
        configureStorage()
        fillUserInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fillUserInformation()
    }
    
    // MARK: - Delegates
    
    // MARK: Firebase functions
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
                self.nameTextField.text = value?[Constants.UserData.name] as? String ?? ""
                self.ageTextField.text = value?[Constants.UserData.age] as? String ?? ""
                self.cityTextField.text = value?[Constants.UserData.city] as? String ?? ""
                self.aboutTextField.text = value?[Constants.UserData.about] as? String ?? ""
                if let imageURL = value?[Constants.UserData.imageURL] as? String {
                    if let cachedImage = self.imageCache.object(forKey: "profileImage") {
                        DispatchQueue.main.async {
                            self.profileImageView.image = cachedImage
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
                                    self.profileImageView.image = userImage
                                }
                            }
                        })
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    // MARK: Assist functions
    // Cut image to screen syze
    func prepareNewImage(image: UIImage) -> Data {
        var newImage = image.resized(toWidth: (self.view.frame.width))!
        let imageWidth: CGFloat = newImage.size.width
        let imageHeight: CGFloat = newImage.size.height
        let width: CGFloat  = imageWidth
        let height: CGFloat = imageHeight
        let origin = CGPoint(x: (imageWidth - width)/2, y: (imageHeight - height)/2)
        let size = CGSize(width: width, height: height)
        newImage = newImage.crop(rect: CGRect(origin: origin, size: size))
        let imageData = newImage.jpeg(.highest)!
        return imageData
    }
    
    func addImageToStorage(image:UIImage) {
        let photoData = prepareNewImage(image: image)
        let imagePath = "users/" + userID! + "/profileImage"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            guard (error == nil) else {
                print("error saving image to storage")
                return
            }
            let imageURL = self.storageRef.child((metadata?.path)!).description
            self.databaseRef.child("users/\(self.userID!)/\(Constants.UserData.imageURL)").setValue(imageURL)
        }
    }
    
    func deleteProfileImageFromStorage() {
        // Create a reference to the file to delete
        let pathToImage = "users/" + userID! + "/profileImage.jpg"
        let desertRef = storageRef.child(pathToImage)
        
        // Delete the file
        desertRef.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        }
    }
    // MARK:  ImagePicker
    func imagePicker(_ type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = type
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //profileImageView.image? = image
            newProfileImage = image
            profileImageChanged = true
            self.imageCache.setObject(image, forKey: "profileImage")
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
            //var userData:[String:String] = [:]
            //userData[Constants.UserData.name] = nameTextField.text ?? ""
            if let userName = nameTextField.text {
                self.databaseRef.child("users/\(userID)/\(Constants.UserData.name)").setValue(userName)
            }
            if let userAge = ageTextField.text {
                self.databaseRef.child("users/\(userID)/\(Constants.UserData.age)").setValue(userAge)
            }
            if let userCity = cityTextField.text {
                self.databaseRef.child("users/\(userID)/\(Constants.UserData.city)").setValue(userCity)
            }
            if let userAbout = aboutTextField.text {
                self.databaseRef.child("users/\(userID)/\(Constants.UserData.about)").setValue(userAbout)
            }
            if let newProfileImage = newProfileImage {
                deleteProfileImageFromStorage()
                addImageToStorage(image: newProfileImage)
            }
            //addImageToStorage(image: profileImageView.image!)
            //databaseRef.child("users").child(userID).setValue(userData)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
