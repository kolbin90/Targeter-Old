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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cancelButton(_ sender: Any) {
        let manager = FBSDKLoginManager()
        manager.logOut()
        self.dismiss(animated: true)
    }
    @IBAction func finishButton(_ sender: Any) {
    }
}
