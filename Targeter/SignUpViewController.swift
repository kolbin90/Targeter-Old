//
//  SignUpViewController.swift
//  Targeter
//
//  Created by Apple User on 12/10/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLineView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailLineView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordLineView: UIView!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        handleTextField()
    }
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(SignUpViewController.usernameTextFieldDidChange), for: UIControl.Event.editingChanged)
        emailTextField.addTarget(self, action: #selector(SignUpViewController.emailTextFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.passwordTextFieldDidChange), for: UIControl.Event.editingChanged)
        
    }
    @objc func usernameTextFieldDidChange() {
        
        guard let username = usernameTextField.text, !username.isEmpty else {
            //signUpButton.isEnabled = false
            usernameLineView.backgroundColor = .red
            return
        }
        
        if isValidUsername(input: username) {
            //signUpButton.isEnabled = true
            Api.user.singleObserveUser(withUsername: username, completion: { (user) in
                self.usernameLineView.backgroundColor = .red
                self.warningLabel.text = "Username is taken"
                self.warningLabel.isHidden = false
                //self.finishButton.isEnabled = false
            }) { (error) in
                self.usernameLineView.backgroundColor = .green
                self.warningLabel.isHidden = true
                //self.finishButton.isEnabled = true
            }
        } else {
            self.usernameLineView.backgroundColor = .red
            self.warningLabel.text = "Only letters, underscores and numbers allowed"
            self.warningLabel.isHidden = false
        }
        
    }
    @objc func emailTextFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty else {
            //signUpButton.isEnabled = false
            emailLineView.backgroundColor = .red
            return
        }
        if isValidEmail(emailStr: email) {
            AuthService.isEmailUsed(email: email) { (value) in
                if value {
                    self.emailLineView.backgroundColor = .red
                    self.warningLabel.text = "Email is already used"
                    self.warningLabel.isHidden = false
                } else {
                    self.emailLineView.backgroundColor = .green
                    self.warningLabel.isHidden = true
                }
            }
            
        } else {
            self.emailLineView.backgroundColor = .red
            self.warningLabel.text = "Email isn't valid"
            self.warningLabel.isHidden = false
        }
        
    }
    @objc func passwordTextFieldDidChange() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            //signUpButton.isEnabled = false
            passwordLineView.backgroundColor = .red
            return
        }
        if isValidPassword(input: password) {
            self.passwordLineView.backgroundColor = .green
            self.warningLabel.isHidden = true
        } else {
            self.passwordLineView.backgroundColor = .red
            self.warningLabel.text = "Password should be 6 symbols minimum"
            self.warningLabel.isHidden = false
        }
        
    }
    
    
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    func isValidUsername(input:String) -> Bool {
        let usernameRegEx = "\\w{1,18}"
        let usernamePred = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernamePred.evaluate(with: input)
    }
    
    func isValidPassword(input:String) -> Bool {
        let passwordRegEx = "\\w{6,}"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: input)
    }
    
    @IBAction func signUpButton_TchUpIns(_ sender: Any) {
        
    }
    
    @IBAction func signInButton_TchUpIns(_ sender: Any) {
    }
    
    
}
