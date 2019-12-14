//
//  SignUpViewController.swift
//  Targeter
//
//  Created by Apple User on 12/10/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var usernameWarningLabel: UILabel!
    @IBOutlet weak var emailWarningLabel: UILabel!
    @IBOutlet weak var passwordWarningLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLineView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailLineView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordLineView: UIView!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookButton.delegate = self
        handleTextField()
    }
    
    // MARK: Handle textfield
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(SignUpViewController.usernameTextFieldDidChange), for: UIControl.Event.editingChanged)
        emailTextField.addTarget(self, action: #selector(SignUpViewController.emailTextFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.passwordTextFieldDidChange), for: UIControl.Event.editingChanged)
        
    }
    @objc func usernameTextFieldDidChange() {
        
        guard let username = usernameTextField.text, !username.isEmpty else {
            usernameLineView.backgroundColor = .red
            setSignUpButton()
            return
        }
        
        if isValidUsername(input: username) {
            Api.user.singleObserveUser(withUsername: username, completion: { (user) in
                self.usernameLineView.backgroundColor = .red
                self.setSignUpButton()
                self.usernameWarningLabel.text = "Username is taken"
                self.usernameWarningLabel.isHidden = false
            }) { (error) in
                self.usernameLineView.backgroundColor = .green
                self.setSignUpButton()
                self.usernameWarningLabel.isHidden = true
            }
        } else {
            usernameLineView.backgroundColor = .red
            setSignUpButton()
            usernameWarningLabel.text = "Only letters, underscores and numbers allowed"
            usernameWarningLabel.isHidden = false
        }
        
    }
    
    @objc func emailTextFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty else {
            emailLineView.backgroundColor = .red
            setSignUpButton()
            return
        }
        if isValidEmail(emailStr: email) {
            AuthService.isEmailUsed(email: email) { (value) in
                if value {
                    self.emailLineView.backgroundColor = .red
                    self.setSignUpButton()
                    self.emailWarningLabel.text = "Email is already used"
                    self.emailWarningLabel.isHidden = false
                } else {
                    self.emailLineView.backgroundColor = .green
                    self.setSignUpButton()
                    self.emailWarningLabel.isHidden = true
                }
            }
            
        } else {
            emailLineView.backgroundColor = .red
            setSignUpButton()
            emailWarningLabel.text = "Email isn't valid"
            emailWarningLabel.isHidden = false
        }
        
    }
    @objc func passwordTextFieldDidChange() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            passwordLineView.backgroundColor = .red
            setSignUpButton()
            return
        }
        if isValidPassword(input: password) {
            self.passwordLineView.backgroundColor = .green
            setSignUpButton()
            passwordWarningLabel.isHidden = true
        } else {
            self.passwordLineView.backgroundColor = .red
            setSignUpButton()
            passwordWarningLabel.text = "Password should be 6 symbols minimum"
            passwordWarningLabel.isHidden = false
        }
        
    }
    
    func setSignUpButton(){
        if usernameLineView.backgroundColor == .green, emailLineView.backgroundColor == .green, passwordLineView.backgroundColor == .green {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
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
    
    
    // MARK: Actions
    @IBAction func signUpButton_TchUpIns(_ sender: Any) {
        ProgressHUD.show("Signing up...")
        AuthService.signUp(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            ProgressHUD.dismiss()
            self.dismiss(animated: true, completion: {
            })
        }) { (error) in
            ProgressHUD.showError(error)
        }
        
    }
    
    @IBAction func signInButton_TchUpIns(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
}
// MARK: - Extensions
// MARK: FBSDKLoginButtonDelegate
extension SignUpViewController: FBSDKLoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if result?.grantedPermissions != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            ProgressHUD.show("Loading...")
            Auth.auth().signIn(with: credential) { (result, error) in
                
                if let result = result {
                    print(result)
                }
                if let error = error {
                    print(error)
                }
                
                Api.user.singleObserveCurrentUser(completion: { (user) in
                    if user.username == nil || user.username == "" {
                        self.fatchFacebookUser(completion: { (dict) in
                            let user = UserModel.transformFaceBookDataToUser(dict: dict)
                            let chooseUsernameVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ChooseUsernameViewController") as! ChooseUsernameViewController
                            AuthService.saveNewUserInfo(profileImageUrl: user.imageURLString, name: user.name, username: user.email, email: user.email)
                            ProgressHUD.dismiss()
                            self.show(chooseUsernameVC, sender: nil)
                        })
                    } else {
                        ProgressHUD.dismiss()
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }, onError: { (errorString) in
                    self.fatchFacebookUser(completion: { (dict) in
                        let user = UserModel.transformFaceBookDataToUser(dict: dict)
                        AuthService.saveNewUserInfo(profileImageUrl: user.imageURLString, name: user.name, username: user.email, email: user.email)
                        ProgressHUD.dismiss()
                        let chooseUsernameVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ChooseUsernameViewController") as! ChooseUsernameViewController
                        self.show(chooseUsernameVC, sender: nil)
                    })
                })
                
            }
        }
    }
    
    func fatchFacebookUser(completion: @escaping  ([String: Any]) -> Void) {
        AuthService.getUserInfoDictionaryFromFacebook { (dict) in
            completion(dict)
        }
    }
}
