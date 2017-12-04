//
//  EditProfileVC.swift
//  Targeter
//
//  Created by mac on 11/30/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import UIKit

class EditProfileViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    
    // MARK: - Delegates
    // MARK: TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    // MARK: Actions
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func changeImageButton(_ sender: Any) {
    }
    
    @IBAction func saveButton(_ sender: Any) {
    }
}
