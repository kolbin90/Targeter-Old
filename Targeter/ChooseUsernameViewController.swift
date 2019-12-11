//
//  ChooseUsernameViewController.swift
//  Targeter
//
//  Created by Apple User on 12/5/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ChooseUsernameViewController: UIViewController {
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    
    var success = false
    deinit {
        if !success {
            logout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        setNavigationController() // Set up Navigation controller
        // Set up Navigation controller
        setNavigationController()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        handleTextField()
        // Do any additional setup after loading the view.
    }
    
    func handleTextField() {
        usernameTextfield.addTarget(self, action: #selector(ChooseUsernameViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let username = usernameTextfield.text, !username.isEmpty else {
            finishButton.isEnabled = false
            lineView.backgroundColor = .red
            return
        }
        if isValidUsername(input: username) {
            finishButton.isEnabled = true
            Api.user.singleObserveUser(withUsername: username, completion: { (user) in
                self.lineView.backgroundColor = .red
                self.warningLabel.text = "Username is taken"
                self.warningLabel.isHidden = false
                self.finishButton.isEnabled = false
            }) { (error) in
                self.lineView.backgroundColor = .green
                self.warningLabel.isHidden = true
                self.finishButton.isEnabled = true
                
            }
        } else {
            self.lineView.backgroundColor = .red
            self.warningLabel.text = "Only letters, underscores and numbers allowed"
            self.warningLabel.isHidden = false
            self.finishButton.isEnabled = false
        }
        
    }
    func isValidUsername(input:String) -> Bool {
        let usernameRegEx = "\\w{1,18}"
        let usernamePred = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernamePred.evaluate(with: input)
    }
    func logout(){
        let manager = FBSDKLoginManager()
        manager.logOut()
        if let user = Api.user.currentUser {
            AuthService.firebaseLogOut()
        }
    }
    

    @IBAction func cancelButton(_ sender: Any) {
        logout()
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func finishButton(_ sender: Any) {
        AuthService.saveNewUserInfo(profileImageUrl: nil, name: nil, username: usernameTextfield.text, email: nil)
        success = true
        self.dismiss(animated: true, completion: nil)
    }
}



