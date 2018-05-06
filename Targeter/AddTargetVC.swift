//
//  AddTargetVC.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuthUI

class AddTargetVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: - Properties
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var editingMode = false
    var target: Target?
    var targetSnapshot: AnyObject?
    var viewLoadedWithImage: UIImage?
    let dateFormatter = DateFormatter()
    let cellHeight:CGFloat = 130
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    let imageCache = (UIApplication.shared.delegate as! AppDelegate).imageCache

    
    //MARK: - Outlets
    
    @IBOutlet weak var actionsStackView: UIStackView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var tergetImageView: UIImageView!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet var dateTF: [UITextField]!
    @IBOutlet weak var addImageButton: UIButton!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up Navigation controller
        setNavigationController()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
        configDatabase()
        configureStorage()
        //deleteButton.tintColor = .red // cell.dot1.image!.withRenderingMode(.alwaysTemplate)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        hideKeyboardWhenTappedAround()
        mainView.layer.cornerRadius = 15
        if editingMode {
            
            
            
            
            
            guard let target = targetSnapshot as? [String:AnyObject] else {
                return
            }
            let title = target[Constants.Target.Title] as? String ?? "Опусти водный бро"
            let description = target[Constants.Target.Description] as? String ?? ""
            let dateBeginning = target[Constants.Target.DateBeginning] as? String ?? ""
            let dateEnding = target[Constants.Target.DateEnding] as? String ?? ""
            let targetID = target[Constants.Target.TargetID] as? String ?? ""
            if let imageURL = target[Constants.Target.ImageURL] as? String {
                    Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX, completion: { (data, error) in
                        guard error == nil else {
                            print("Error downloading: \(error!)")
                            return
                        }
                        if let userImage = UIImage.init(data: data!, scale: 50) {
                         //   self.imageCache.setObject(userImage, forKey: "targetImage\(indexPath.row)" as NSString)
                            DispatchQueue.main.async {
                                self.tergetImageView.image = userImage
                            }
                        }
                    })
                
            }
            
            
            
            
            
            titleTF.text = title
            descriptionTF.text = description
            startDate.isEnabled = false
            startDate.alpha = 0.5
            startDate.text = dateBeginning
            addImageButton.setTitle("Change image", for: .normal)
            
            if dateEnding != "" {
                endDate.isEnabled = true
                endDate.text = dateEnding
            }
            navigationItem.title = "Edit target"
            actionsStackView.isHidden = false
        } 
    }
    
    //MARK: - UITextFieldDelegatye
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    //MARK: - ImagePicker
    func imagePicker(_ type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = type
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            tergetImageView.image = image
            addImageButton.setTitle("Change image", for: .normal)
        }
        dismiss(animated: true, completion: nil)
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    //MARK: - Assist functions
    
    // MARK: Firebase functions
    func configDatabase(){
        databaseRef = Database.database().reference()
    }
    func configureStorage() {
        storageRef = Storage.storage().reference()
    }
    func addImageToStorage(image:UIImage, targetRef:DatabaseReference, targetID:String) {
        let photoData = image.jpeg(.highest)!
        let imagePath = Constants.RootFolders.Targets  + "/" + targetID + "/targetImage\(Date())"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            guard (error == nil) else {
                print("error saving image to storage")
                return
            }
            // Save URL to Database
            let imageURL = self.storageRef.child((metadata?.path)!).description
            targetRef.child(Constants.Target.ImageURL).setValue(imageURL)
        }
    }
    
    func deleteTargetAlertController(target: Target) {
        let actionController = UIAlertController(title: "Delete Target", message: "Are you sure to delete? You can't undo this", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            DispatchQueue.main.async {
                self.stack.context.delete(target)
                self.stack.save()
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionController.addAction(deleteAction)
        actionController.addAction(cancelAction)
        self.present(actionController, animated: true, completion: nil)
    }
    

   
    // Check if textFields have text inside
    func TFAreFilled() -> Bool {
        guard titleTF.text !=  "" else {
            showAlert(title: "Error", error: "Fill the Title field")
            return false
        }
        guard tergetImageView.image != nil else {
            showAlert(title: "Error", error: "Choose picture for your target")
            return false
        }
        guard startDate.text != "" else {
            showAlert(title: "Error", error: "Choose beginning day")
            return false
        }
        if endDate.isEnabled {
            guard endDate.text != "" else {
                showAlert(title: "Error", error: "Choose finishing day")
                return false
            }
        }
        return true
    }
    
    @objc func datePickerValueChanged(sender:UIDatePickerWithSenderTag) {
        if sender.senderTag! == 1 {
            startDate.text = dateFormatter.string(from: sender.date)
        } else if sender.senderTag! == 2 {
            endDate.text = dateFormatter.string(from: sender.date)
        }
    }
    
    class UIDatePickerWithSenderTag:UIDatePicker {
        var senderTag: Int?
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func deleteButton(_ sender: Any) {
        deleteTargetAlertController(target: target!)
    }
    

    @IBAction func completeButton(_ sender: Any) {
        target?.completed = true
        stack.save()
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func addImageButton(_ sender: Any) {
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
    
    
    @IBAction func doneButton(_ sender: Any) {
        // Check if fields are filled with text
        if TFAreFilled() {
            let startDateFromString = dateFormatter.date(from: startDate.text!)!
            let endDateFromString:Date?
            if endDate.isEnabled {
                endDateFromString = dateFormatter.date(from: endDate.text!)
            } else {
                endDateFromString = nil
            }
            var imageData:Data?
            var cellImageData:Data?

            if editingMode {
                guard let target = targetSnapshot as? [String:AnyObject] else {
                    return
                }
                
                let image = tergetImageView.image!
                if let userID = userID {
                    // Create targetRef to get a unique name for target in Firebase
                    let targetID = target[Constants.Target.TargetID] as? String ?? ""
                    let targetRef = databaseRef.child(Constants.RootFolders.Targets).child(userID).child(targetID)
                    targetRef.child(Constants.Target.TargetID).setValue(targetID)
                    targetRef.child(Constants.Target.Title).setValue(titleTF.text)
                    targetRef.child(Constants.Target.Description).setValue(descriptionTF.text!)
                    targetRef.child(Constants.Target.DateBeginning).setValue(startDate.text!)
                    if let endDateText = endDate.text, endDateText != "" {
                        targetRef.child(Constants.Target.DateEnding).setValue(endDateText)
                    }
                    addImageToStorage(image: image, targetRef: targetRef, targetID: targetID)
                }
            } else {
                //imageData = prepareNewImage(image: tergetImageView.image!)
                imageData = tergetImageView.image?.jpeg(.highest)
                let image = tergetImageView.image!
                // Create new target
                if let userID = userID {
                    // Create targetRef to get a unique name for target in Firebase
                    let targetRef = databaseRef.child(Constants.RootFolders.Targets).child(userID).childByAutoId()
                    let targetID = targetRef.key
                    targetRef.child(Constants.Target.TargetID).setValue(targetID)
                    targetRef.child(Constants.Target.Title).setValue(titleTF.text)
                    targetRef.child(Constants.Target.Description).setValue(descriptionTF.text!)
                    targetRef.child(Constants.Target.DateBeginning).setValue(startDate.text!)
                    if let endDateText = endDate.text, endDateText != "" {
                        targetRef.child(Constants.Target.DateEnding).setValue(endDateText)
                    }
                    addImageToStorage(image: image, targetRef: targetRef, targetID: targetID)
                }
            }
            _ = navigationController?.popViewController(animated: true)
            
        }
    }
    
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        endDate.isEnabled = sender.isOn
        if endDate.isEnabled {
            endDate.alpha = 1
        } else {
            endDate.alpha = 0.3
        }
    }
    @IBAction func dateTF(_ sender: UITextField) {
        if sender.text == nil || sender.text == "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.string(from: Date())
            sender.text = date
        }
        let datePickerView = UIDatePickerWithSenderTag()
        datePickerView.senderTag = sender.tag
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.minimumDate = Date()
        datePickerView.maximumDate = Calendar.current.date(byAdding: .year, value: 100, to: Date())!
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 45))
        let flexibleSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexibleSeparator, doneButton]
        toolbar.barTintColor = .groupTableViewBackground
        toolbar.tintColor = .black
        sender.inputAccessoryView = toolbar
        
    }
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? ImageFromFlickerVC {
            tergetImageView.image = sourceViewController.imageView.image!
        }
    }
    
}
