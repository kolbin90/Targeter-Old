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

    var user: UserModel?
    deinit {
        logout()
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

        // Do any additional setup after loading the view.
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
        AuthService.saveNewUserInfo(profileImageUrl: user!.imageURLString!, name: user!.name!, username: "Patrick")
        self.dismiss(animated: true, completion: nil)
    }
}
