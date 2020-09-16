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
    }
    @IBAction func saveButton_TchUpIns(_ sender: Any) {
    }
    
    @IBAction func cancelButton_TchUpIns(_ sender: Any) {
    }
    
}
