//
//  SignInViewController.swift
//  Targeter
//
//  Created by Apple User on 12/3/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordLineView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailLineView: UIView!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    @IBOutlet weak var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookButton.delegate = self
        facebookButton.readPermissions = ["public_profile", "email"]
        
        hideKeyboardWhenTappedAround()
        
        handleTextField()
        signInButton.isEnabled = false
        
        // Set up Navigation controller
        setNavigationController()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
    }
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(SignUpViewController.emailTextFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.passwordTextFieldDidChange), for: UIControl.Event.editingChanged)
        
    }
    @objc func emailTextFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty else {
            emailLineView.backgroundColor = .red
            setSignInButton()
            return
        }
        if isValidEmail(emailStr: email) {
            self.emailLineView.backgroundColor = .green
            self.setSignInButton()   
        } else {
            emailLineView.backgroundColor = .red
            setSignInButton()
        }
        
    }
    @objc func passwordTextFieldDidChange() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            passwordLineView.backgroundColor = .red
            setSignInButton()
            return
        }
        if isValidPassword(input: password) {
            self.passwordLineView.backgroundColor = .green
            setSignInButton()
        } else {
            self.passwordLineView.backgroundColor = .red
            setSignInButton()
        }
        
    }
    
    func setSignInButton(){
        if emailLineView.backgroundColor == .green, passwordLineView.backgroundColor == .green {
            signInButton.isEnabled = true
        } else {
            signInButton.isEnabled = false
        }
    }
    
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    func isValidPassword(input:String) -> Bool {
        let passwordRegEx = "\\w{6,}"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: input)
    }
    
    @IBAction func forgotPasswordButton(_ sender: Any) {
    }
    @IBAction func signUpButton(_ sender: Any) {
    }
    @IBAction func signInButton_TchUpIns(_ sender: Any) {
        ProgressHUD.show("Signing in...")
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, OnSuccess: {
            ProgressHUD.dismiss()
            self.dismiss(animated: true, completion: {
            })
        }) { (error) in
            ProgressHUD.showError(error)
        }
    }
    
}



extension SignInViewController: FBSDKLoginButtonDelegate {
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

