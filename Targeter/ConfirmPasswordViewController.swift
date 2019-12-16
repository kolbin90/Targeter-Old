//
//  ConfirmPasswordViewController.swift
//  Targeter
//
//  Created by Apple User on 12/16/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit
import FBSDKLoginKit


class ConfirmPasswordViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordLineView: UIView!
    @IBOutlet weak var passwordWarningLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: Variables
    var success = false
    
    // MARK: Init
    deinit {
        if !success {
            logout()
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        // Set up Navigation controller
        setNavigationController()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        handleTextField()
    }
    // MARK: Handle textfield
    func handleTextField() {
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.passwordTextFieldDidChange), for: UIControl.Event.editingChanged)
        
    }
    
    @objc func passwordTextFieldDidChange() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            passwordLineView.backgroundColor = .red
            confirmButton.isEnabled = false
            return
        }
        if isValidPassword(input: password) {
            self.passwordLineView.backgroundColor = .green
            confirmButton.isEnabled = true
            passwordWarningLabel.isHidden = true
        } else {
            self.passwordLineView.backgroundColor = .red
            confirmButton.isEnabled = false
            passwordWarningLabel.text = "Password should be 6 symbols minimum"
            passwordWarningLabel.isHidden = false
        }
        
    }
    
    func isValidPassword(input:String) -> Bool {
        let passwordRegEx = "\\w{6,}"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: input)
    }
    
    // MARK: Assist methods
    func logout(){
        let manager = FBSDKLoginManager()
        manager.logOut()
        if let user = Api.user.currentUser {
            AuthService.firebaseLogOut()
        }
    }
    

    // MARK: Actions
    @IBAction func confirmButton_TchUpIns(_ sender: Any) {
        
    }
    @IBAction func cancelButton(_ sender: Any) {
    }
}
