//
//  ForgotPasswordViewController.swift
//  Targeter
//
//  Created by Apple User on 12/17/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit
protocol ForgotPasswordViewControllerDelegate {
    func fillEmailTextField(email: String)
}
class ForgotPasswordViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailLineView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: Variables
    var email: String?
    var delegate: ForgotPasswordViewControllerDelegate?

    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        handleTextField()
        // Do any additional setup after loading the view.
        if let email = email {
            emailTextField.text = email
        }
    }
    
    // MARK: Handle textfield
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(SignUpViewController.emailTextFieldDidChange), for: UIControl.Event.editingChanged)
        
    }
    @objc func emailTextFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty else {
            emailLineView.backgroundColor = .red
            confirmButton.isEnabled = false
            return
        }
        if isValidEmail(emailStr: email) {
            self.emailLineView.backgroundColor = .green
            self.confirmButton.isEnabled = true
        } else {
            emailLineView.backgroundColor = .red
            confirmButton.isEnabled = false
        }
        
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    
    // MARK: Actions
    @IBAction func cancelButton_TchUpIns(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmButton_TchUpIns(_ sender: Any) {
        ProgressHUD.show("Sending...")
        AuthService.sendPasswordReset(withEmail: emailTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Sent. Check your email")
            self.delegate?.fillEmailTextField(email: self.emailTextField.text!)
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in
            ProgressHUD.showError(error)
        }
    }
}
