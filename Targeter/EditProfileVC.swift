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
import CoreData

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    var profileImageChanged = false
    var newProfileImage: UIImage? = nil
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var imageURLforRef: String?
    
    
    // MARK: Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
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
            // Create and set fetchrequest
            let fetchRequest:NSFetchRequest<ProfileImage> = ProfileImage.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "userID", ascending: false)
            let predicate = NSPredicate(format:"userID = %@", userID)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = predicate
            
            databaseRef.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user data and fill fields
                let value = snapshot.value as? NSDictionary
                self.nameTextField.text = value?[Constants.UserData.Name] as? String ?? ""
                self.ageTextField.text = value?[Constants.UserData.Age] as? String ?? ""
                self.cityTextField.text = value?[Constants.UserData.City] as? String ?? ""
                self.aboutTextField.text = value?[Constants.UserData.About] as? String ?? ""
                self.usernameTextField.text = value?[Constants.UserData.Username] as? String ?? ""
                if !self.profileImageChanged {
                    // Do nothing, because we set new image in picker controller
                } else {
                    // Check if we have image URL
                    if let imageURL = value?[Constants.UserData.ImageURL] as? String {
                        self.imageURLforRef = imageURL
                        DispatchQueue.main.async {
                            // Check if we have image in Core Data
                            if let result = try? self.stack.context.fetch(fetchRequest) {
                                if result.count > 0 {
                                    let profileImage = result[0]
                                    // Check if it's the same image that we need, if so use it
                                    if profileImage.imageURL == imageURL {
                                        self.profileImageView.image = UIImage(data: profileImage.imageData)
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
                                                    self.profileImageView.image = userImage
                                                    self.stack.save()
                                                }
                                            }
                                        })
                                    }
                                } else {
                                    // If we have noting in CoreDta we download image from Firebase and save it to core data
                                    Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX, completion: { (data, error) in
                                        guard error == nil else {
                                            print("Error downloading: \(error!)")
                                            return
                                        }
                                        
                                        if let userImage = UIImage.init(data: data!) {
                                            DispatchQueue.main.async {
                                                _ = ProfileImage(userID: userID, imageData: data!, imageURL: imageURL, context: self.stack.context)
                                                self.profileImageView.image = userImage
                                                self.stack.save()
                                            }
                                        }
                                    })
                                }
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
    
    // Save image to Firebase storage, save image URL to Firebase database
    func addImageToStorage(image:UIImage) {
        let photoData = prepareNewImage(image: image)
        let imagePath = "users/" + userID! + "/profileImage/\(Date())"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            guard (error == nil) else {
                print("error saving image to storage")
                return
            }
            let imageURL = self.storageRef.child((metadata?.path)!).description
            let fetchRequest:NSFetchRequest<ProfileImage> = ProfileImage.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "userID", ascending: false)
            let predicate = NSPredicate(format:"userID = %@", self.userID!)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = predicate
            if let result = try? self.stack.context.fetch(fetchRequest) {
                if result.count > 0 {
                    let profileImage = result[0]
                    self.stack.context.delete(profileImage)
                    _ = ProfileImage(userID: self.userID!, imageData: photoData, imageURL: imageURL, context: self.stack.context)
                    self.stack.save()
                    
                } else {
                    _ = ProfileImage(userID: self.userID!, imageData: photoData, imageURL: imageURL, context: self.stack.context)
                    self.stack.save()
                }
            }
            self.databaseRef.child("users/\(self.userID!)/\(Constants.UserData.ImageURL)").setValue(imageURL)
        }
    }
    
    // Delete old profile image from firebase storage
    func deleteProfileImageFromStorage() {
        // Create a reference to the file to delete
        if let imageURLforRef = imageURLforRef {
            let deleteRef = Storage.storage().reference(forURL: imageURLforRef)
            // Delete the file
            deleteRef.delete { error in
                if let error = error {
                    // Uh-oh, an error occurred!
                } else {
                    // File deleted successfully
                }
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
            self.profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: Actions
    
    @IBAction func cancelButton(_ sender: Any) {
        // Closw VC
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
        // Save data to Firebase
        if let userID = userID {
            if let name = nameTextField.text {
                self.databaseRef.child("\(Constants.RootFolders.Users)/\(userID)/\(Constants.UserData.Name)").setValue(name)
            }
            if let username = usernameTextField.text {
                self.databaseRef.child("\(Constants.RootFolders.Users)/\(userID)/\(Constants.UserData.Username)").setValue(username)
            }
            if let age = ageTextField.text {
                self.databaseRef.child("\(Constants.RootFolders.Users)/\(userID)/\(Constants.UserData.Age)").setValue(age)
            }
            if let city = cityTextField.text {
                self.databaseRef.child("\(Constants.RootFolders.Users)/\(userID)/\(Constants.UserData.City)").setValue(city)
            }
            if let about = aboutTextField.text {
                self.databaseRef.child("\(Constants.RootFolders.Users)/\(userID)/\(Constants.UserData.About)").setValue(about)
            }
            if let newProfileImage = newProfileImage {
                deleteProfileImageFromStorage()
                addImageToStorage(image: newProfileImage)

            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
