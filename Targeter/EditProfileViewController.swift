//
//  EditProfileViewController.swift
//  Targeter
//
//  Created by Alexander Kolbin on 8/15/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation

class EditProfileViewController: UITableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleTextField()
    }
    // MARK: Variables
    var profileImagesHasChanged = false
    
    // MARK: Handle textfield
    func handleTextField() {
        locationTextField.addTarget(self, action: #selector(EditProfileViewController.locationLabelDidChange), for: UIControl.Event.editingChanged)
        nameTextField.addTarget(self, action: #selector(EditProfileViewController.nameTextFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func locationLabelDidChange() {
        guard let locationText = locationTextField.text, !locationText.isEmpty else {
            locationLabel.text = ""
            locationLabel.isHidden = true
            return
        }
        locationLabel.text = " \(locationText) "
        locationLabel.isHidden = false
        
//        guard let startText = startTextField.text, !startText.isEmpty, let _ = cell.targetImageView.image else {
//            addTargetButton.setTitleColor(.lightGray, for: .normal)
//            addTargetButton.isEnabled = false
//            return
//        }
//        addTargetButton.setTitleColor(.black, for: .normal)
//        addTargetButton.isEnabled = true
    }
    
    @objc func nameTextFieldDidChange() {
        guard let nameText = nameTextField.text, !nameText.isEmpty else {
            nameLabel.text = ""
            nameLabel.isHidden = true
            return
        }
        nameLabel.text = " \(nameText) "
        nameLabel.isHidden = false
        
    }
    
    
    @IBAction func chooseImageButton_TchUpIns(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    @IBAction func saveButton_TchUpIns(_ sender: Any) {
        ProgressHUD.show("Saving")
        let name = nameTextField.text
        let location = locationTextField.text
        guard let userId = Api.user.currentUser?.uid  else {
            ProgressHUD.showError()
            return
        }
        Api.user.uploadProfileToServer(image: profileImageView.image, name: name, location: location, userId: userId, onSuccess: {
            ProgressHUD.showSuccess()
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            ProgressHUD.showError(error)
        }
    }
    
    @IBAction func cancelButton_TchUpIns(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Extensions
// MARK: UIImagePickerControllerDelegate, AddTargetTableViewController
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                //cell.targetImageView.image = image
                //selectedImage = image
                ProgressHUD.show("Loading...")
                let cropImageVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "CropProfileImageViewController") as! CropProfileImageViewController
                cropImageVC.image = image
                cropImageVC.delegate = self
                ProgressHUD.dismiss()
                self.navigationController?.show(cropImageVC, sender: nil)
                
//                let navController = UINavigationController(rootViewController: cropImageVC)
//                self.present(navController, animated: true, completion: {
//                    ProgressHUD.dismiss()
//                })
            }
        }

    }
}

// MARK: EditProfileViewController
extension EditProfileViewController: CropProfileImageViewControllerDelegate {
    func setImage(_ image: UIImage) {
        profileImageView.image = image
        profileImagesHasChanged = true
        
        
        //cell.updateFocusIfNeeded()
        //textFieldDidChange()
    }
}
