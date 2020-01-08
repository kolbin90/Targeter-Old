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
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewTargetCell", bundle: nil), forCellReuseIdentifier: "NewTargetCell")
        observeTargets()
        
        // Do any additional setup after loading the view.
    }
    
    func observeTargets() {
        Api.target.observeTargets(completion: { (target) in
            self.targets.append(target)
            self.tableView.reloadData()
        }) { (error) in
            ProgressHUD.showError(error)
        }
    }
    
    @IBAction func addTargetButton_TchUpIns(_ sender: Any) {
    }
    
}

extension TargetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewTargetCell", for: indexPath) as! NewTargetCell
        cell.cellTarget = targets[indexPath.row]
        
        return cell
        
    }
    
}
