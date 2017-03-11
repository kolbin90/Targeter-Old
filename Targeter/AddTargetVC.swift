//
//  AddTargetVC.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit
import CoreData

class AddTargetVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Variables
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    //MARK: - Outlets
    
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var tergetImageView: UIImageView!

    //MARK: - ImagePicker
    
    func imagePicker(_ type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = type
        self.present(imagePicker, animated: true, completion: nil)
    }
    
       // imagePicker(.photoLibrary)
       // imagePicker(.camera)
  
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            tergetImageView.image? = image
        }
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
  
    //MARK: - Actions
    
    
    @IBAction func addImageButton(_ sender: Any) {
        
        imagePicker(.photoLibrary)
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
    }

    
}
