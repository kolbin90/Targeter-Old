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
    @IBOutlet weak var usernameTextFieldl: UITextField!
    @IBOutlet weak var usernameLineView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailLineView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordLineView: UIView!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }

    @IBAction func signUpButton_TchUpIns(_ sender: Any) {
        
    }
    
    @IBAction func signInButton_TchUpIns(_ sender: Any) {
    }
    

}
