//
//  TargetsViewController.swift
//  Targeter
//
//  Created by Apple User on 12/28/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit
import SwipeCellKit

class TargetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var targets: [TargetModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationController()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
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
        cell.delegate = self
        
        return cell
        
    }
    
}

extension TargetsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
}
