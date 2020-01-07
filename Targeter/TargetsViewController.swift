//
//  TargetsViewController.swift
//  Targeter
//
//  Created by Apple User on 12/28/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit

class TargetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var targets: [TargetModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeTargets()
        
        // Do any additional setup after loading the view.
    }
    
    func observeTargets() {
        Api.target.observeTargets(completion: { (target) in
            self.targets.append(target)
        }) { (error) in
            ProgressHUD.showError(error)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func addTargetButton_TchUpIns(_ sender: Any) {
    }
    
}
