//
//  AddTargetTableViewController.swift
//  Targeter
//
//  Created by Apple User on 12/30/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit

class AddTargetTableViewController: UITableViewController {

    @IBOutlet weak var addTargetButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var cell: NewTargetCell!
    
    let dateFormatter = DateFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController()
        handleTextField()
        textFieldDidChange()
        dateFormatter.dateFormat = "MM-dd-yyyy"
    }
    
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
        
        guard let startText = startTextField.text, !startText.isEmpty else {
            addTargetButton.setTitleColor(.lightGray, for: .normal)
            addTargetButton.isEnabled = false
            return
        }
        addTargetButton.setTitleColor(.black, for: .normal)
        addTargetButton.isEnabled = true
    }
    @objc func textFieldDidChange() {
        guard let title = titleTextField.text, !title.isEmpty, let start = startTextField.text, !start.isEmpty else {
            addTargetButton.setTitleColor(.lightGray, for: .normal)
            addTargetButton.isEnabled = false
            return
        }
        addTargetButton.setTitleColor(.black, for: .normal)
        addTargetButton.isEnabled = true
    }
    
    
    
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

    
    

    @IBAction func startTextField_EditingDidBegin(_ sender: UITextField) {
        setPickerView(forTextfield: sender)
        
        
    }
    @IBAction func addTargetButton_TchUpIns(_ sender: Any) {
    }
    @IBAction func chooseImageButton_TchUpIns(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
}

extension AddTargetTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cell.targetImageView.image = image
            //selectedImage = image
        }
        dismiss(animated: true, completion: nil)
    }
}
