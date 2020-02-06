//
//  AddTargetTableViewController.swift
//  Targeter
//
//  Created by Apple User on 12/30/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit

// MARK: - AddTargetTableViewController
class AddTargetTableViewController: UITableViewController {
    // MARK: Outlets
    @IBOutlet weak var addTargetButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var cell: NewTargetCell!
    // MARK: Variables
    
    let dateFormatter = DateFormatter()
   
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController(largeTitleDisplayMode: .always)

        handleTextField()
        textFieldDidChange()
        cell.targetImageView.backgroundColor = UIColor.random()
        dateFormatter.dateFormat = "MM-dd-yyyy"
    }
    // MARK: Handle textfield

    func handleTextField() {
        titleTextField.addTarget(self, action: #selector(AddTargetTableViewController.titleTextFieldDidChange), for: UIControl.Event.editingChanged)
        startTextField.addTarget(self, action: #selector(AddTargetTableViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    @objc func titleTextFieldDidChange() {
        
        guard let titleText = titleTextField.text, !titleText.isEmpty else {
            cell.titleLabel.text = ""
            return
        }
        cell.titleLabel.text = " \(titleText) "
        
        guard let startText = startTextField.text, !startText.isEmpty, let _ = cell.targetImageView.image else {
            addTargetButton.setTitleColor(.lightGray, for: .normal)
            addTargetButton.isEnabled = false
            return
        }
        addTargetButton.setTitleColor(.black, for: .normal)
        addTargetButton.isEnabled = true
    }
    @objc func textFieldDidChange() {
        guard let title = titleTextField.text, !title.isEmpty, let start = startTextField.text, !start.isEmpty, let _ = cell.targetImageView.image else {
            addTargetButton.setTitleColor(.lightGray, for: .normal)
            addTargetButton.isEnabled = false
            return
        }
        addTargetButton.setTitleColor(.black, for: .normal)
        addTargetButton.isEnabled = true
    }
    
    
    // MARK: Set date picker

    func setPickerView(forTextfield textField: UITextField ) {
        let datePickerView = UIDatePickerWithSenderTag()
        datePickerView.senderTag = textField.tag
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.minimumDate = Date()
        datePickerView.maximumDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())!
        
        textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 45))
        let flexibleSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexibleSeparator, doneButton]
        toolbar.barTintColor = .groupTableViewBackground
        toolbar.tintColor = .black
        textField.inputAccessoryView = toolbar
    }
    
    @objc func datePickerValueChanged(sender:UIDatePickerWithSenderTag) {
        if dateFormatter.string(from: sender.date) == dateFormatter.string(from: Date()) {
            startTextField.text = "Today"

        } else {
            startTextField.text = dateFormatter.string(from: sender.date)
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

    
    
    // MARK: Actions

    @IBAction func startTextField_EditingDidBegin(_ sender: UITextField) {
        setPickerView(forTextfield: sender)
        
        
    }
    @IBAction func cancelButton_TchUpIns(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func addTargetButton_TchUpIns(_ sender: Any) {
        ProgressHUD.show("Adding...")
        var startDate: Int?
        if startTextField.text == "Today" {
            startDate = Int(Date().timeIntervalSince1970)
        } else {
            startDate = Int(dateFormatter.date(from: startTextField.text!)!.timeIntervalSince1970)
        }
        Api.target.uploadTargetToServer(image: cell.targetImageView.image!, title: titleTextField.text!, start: startDate!, onSuccess: {
            ProgressHUD.showSuccess()
            self.navigationController?.popViewController(animated: true)
        }) { (errorString) in
            ProgressHUD.showError(errorString)
        }
    }
    @IBAction func chooseImageButton_TchUpIns(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
}
// MARK: - Extensions
// MARK: UIImagePickerControllerDelegate, AddTargetTableViewController
extension AddTargetTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                //cell.targetImageView.image = image
                //selectedImage = image
                ProgressHUD.show("Loading...")
                let cropImageVC = UIStoryboard.init(name: "Targets", bundle: nil).instantiateViewController(withIdentifier: "CropImageViewController") as! CropImageViewController
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
// MARK: AddTargetTableViewController

extension AddTargetTableViewController: CropImageViewControllerDelegate {
    func setImage(_ image: UIImage) {
        cell.targetImageView.image = image
        cell.updateFocusIfNeeded()
        textFieldDidChange()
    }
}
