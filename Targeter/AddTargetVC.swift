//
//  AddTargetVC.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit
import CoreData

class AddTargetVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: - Variables
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var weekdaysStackView: UIStackView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var tergetImageView: UIImageView!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!

    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
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
        }
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UITextFieldDelegatye
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Format Date of Birth dd-MM-yyyy
        
        //initially identify your textfield
        
        if textField == startDate {
            
            // check the chars length dd -->2 at the same time calculate the dd-MM --> 5
            if (startDate.text?.characters.count == 2) || (startDate.text?.characters.count == 5) {
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    startDate.text = (startDate.text)! + "-"
                }
            }
            // check the condition not exceed 9 chars
            return !(textField.text!.characters.count > 9 && (string.characters.count ) > range.length)
        }
        else {
            return true
        }
    }
    //MARK: - Keyboard settgs
    
    // Hide keyboard when tapped somewhere
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Actions
    
    
    @IBAction func addImageButton(_ sender: Any) {
        
        //imagePicker(.photoLibrary)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default) { action in
            self.imagePicker(.photoLibrary)
            
        })
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default){ action in
            self.imagePicker(.camera)
            
        })
        
        actionSheet.addAction(UIAlertAction(title: "Download from Flickr", style: .default) { action in
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ImageFromFlickerVC") as! ImageFromFlickerVC
            self.navigationController?.pushViewController(controller, animated: true)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
        
    }
    @IBAction func doneButton(_ sender: Any) {
        let date = Date()
        var imageData:Data?
        if tergetImageView.image != nil {
            imageData = UIImagePNGRepresentation(tergetImageView.image!)
            
        } else {
            imageData = nil
        }
        let newTarget = Target(title: titleTF.text!, descriptionCompletion: descriptionTF.text!, dayBeginning: date, dayEnding: date, picture: imageData, active: true, completed: false, context: stack.context)
        print(newTarget)
        stack.save()
        navigationController?.popViewController(animated: true)
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
            weekdaysStackView.isHidden = sender.isOn
    }
    
}
