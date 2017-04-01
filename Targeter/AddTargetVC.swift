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
    
    //MARK: - Properties
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var editingMode = false
    var target: Target?
    var viewLoadedWithImage: UIImage?
    let dateFormatter = DateFormatter()
    let cellHeight:CGFloat = 130
    
    //MARK: - Outlets
    
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
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        hideKeyboardWhenTappedAround()
        mainView.layer.cornerRadius = 15
        if editingMode {
            titleTF.text = target!.title
            descriptionTF.text = target!.descriptionCompletion
            viewLoadedWithImage = UIImage(data:target!.picture!)
            tergetImageView.image = viewLoadedWithImage
            startDate.isEnabled = false
            startDate.alpha = 0.5
            startDate.text = dateFormatter.string(from: target!.dayBeginning)
            addImageButton.setTitle("Change image", for: .normal)
            
            if let endingDate = target!.dayEnding {
                endDate.isEnabled = true
                endDate.text = dateFormatter.string(from: endingDate)
            }
            navigationItem.title = "Edit target"
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
    
    func prepareNewImage(image: UIImage) -> Data {
        var newImage = image.resized(toWidth: (self.view.frame.width))!
        let imageWidth: CGFloat = newImage.size.width
        let imageHeight: CGFloat = newImage.size.height
        let width: CGFloat  = imageWidth //image.size.width
        let height: CGFloat = 130.0
        let origin = CGPoint(x: (imageWidth - width)/2, y: (imageHeight - height)/2)
        let size = CGSize(width: width, height: height)
        
        newImage = newImage.crop(rect: CGRect(origin: origin, size: size))
        
        //newImage = cropToBounds(image: newImage!, width: Double((newImage?.size.width)!), height: Double(cellHeight))
        let imageData = newImage.jpeg(.highest)!
        return imageData
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
    
    func datePickerValueChanged(sender:UIDatePickerWithSenderTag) {
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
    
    
    @IBAction func addImageButton(_ sender: Any) {
        
        //imagePicker(.photoLibrary)
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
            //TODO: Scale image for future showing in
            /*
             if tergetImageView.image != nil {
             imageData = tergetImageView.image!.jpeg(.highest)
             } else {
             imageData = nil
             }
             */
            // TODO: Check if picture wasn't change and don't do anything with that
            if editingMode {
                target!.title = titleTF.text!
                target!.descriptionCompletion = descriptionTF.text!
                if viewLoadedWithImage != tergetImageView.image! {
                    imageData = prepareNewImage(image: tergetImageView.image!)
                    target!.picture = imageData

                }
                //imageData = tergetImageView.image!.jpeg(.highest)
                target!.dayEnding = endDateFromString
                stack.save()
            } else {
                imageData = prepareNewImage(image: tergetImageView.image!)
                //newImage = cropToBounds(image: newImage!, width: Double((newImage?.size.width)!), height: Double(cellHeight))
                //imageData = newImage?.jpeg(.highest)
                // Create new target
                _ = Target(title: titleTF.text!, descriptionCompletion: descriptionTF.text!, dayBeginning: startDateFromString, dayEnding: endDateFromString, picture: imageData, active: true, completed: false, context: stack.context)
                stack.save()
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
            dateFormatter.dateStyle = .medium
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
