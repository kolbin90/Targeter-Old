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
    @IBOutlet weak var emailTextField: UITextField!
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
        emailTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        
    }
    
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            signInButton.isEnabled = false
            return
        }
        signInButton.isEnabled = true
    }

    @IBAction func forgotPasswordButton(_ sender: Any) {
    }
    @IBAction func signUpButton(_ sender: Any) {
    }
    @IBAction func signInButton_TchUpIns(_ sender: Any) {
    }
    
}
extension SignInViewController: FBSDKLoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
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
            })
            
        }
    }
    
    func fatchFacebookUser(completion: @escaping  ([String: Any]) -> Void) {
        AuthService.getUserInfoDictionaryFromFacebook { (dict) in
            completion(dict)            
        }
    }
}

