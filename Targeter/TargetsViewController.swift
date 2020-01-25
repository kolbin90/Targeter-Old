//
//  TargetsViewController.swift
//  Targeter
//
//  Created by Apple User on 12/28/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit
import SwipeCellKit
protocol TargetsViewControllerDelegate {
    func cellSwiped(withResult result: CheckInModel.CheckInResult)
}

// MARK: - TargetsViewController

class TargetsViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    // MARK: Variables
    var targets: [TargetModel] = []
    var delegates = [String: TargetsViewControllerDelegate]()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationController(largeTitleDisplayMode: .never)

        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewTargetCell", bundle: nil), forCellReuseIdentifier: "NewTargetCell")
        observeTargets()
        
        // Do any additional setup after loading the view.
    }
    // MARK: Assist methods
    func observeTargets() {
        Api.target.observeTargets(completion: { (target) in
            self.targets.append(target)
            self.tableView.reloadData()
        }) { (error) in
            ProgressHUD.showError(error)
        }
    }
    
    // MARK: Actions
    @IBAction func addTargetButton_TchUpIns(_ sender: Any) {
    }
    
}
// MARK: - Extensions
// MARK: UITableViewDataSource, UITableViewDelegate
extension TargetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewTargetCell", for: indexPath) as! NewTargetCell
        cell.cellTarget = targets[indexPath.row]
        cell.delegate = self
        delegates["\(indexPath.row)"] = cell
        
        return cell
        
    }
    
}
// MARK: SwipeTableViewCellDelegate
extension TargetsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left  {
            let succeedAction = SwipeAction(style: .default, title: "Succeed") { action, indexPath in
                // handle action by updating model with deletion
                guard let targetId = self.targets[indexPath.row].id else {
                    return
                }
                tableView.cellForRow(at: indexPath)
                Api.target.saveCheckInToDatabase(result: "S", targetId: targetId, onSuccess: {
                    if let delegate = self.delegates["\(indexPath.row)"] {
                        delegate.cellSwiped(withResult: .succeed)
                    }
                }, onError: { (error) in
                    ProgressHUD.showError(error)
                })
            }
            // customize the action appearance
            succeedAction.backgroundColor = UIColor.greenColor()
            succeedAction.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
            return [succeedAction]
            
        } else {
            
            let failedAction = SwipeAction(style: .default, title: "Failed") { action, indexPath in
                // handle action by updating model with deletion
                guard let targetId = self.targets[indexPath.row].id else {
                    return
                }
                Api.target.saveCheckInToDatabase(result: "F", targetId: targetId, onSuccess: {
                    if let delegate = self.delegates["\(indexPath.row)"] {
                        delegate.cellSwiped(withResult: .failed)
                    }
                }, onError: { (error) in
                    ProgressHUD.showError(error)
                })
            }
            
            // customize the action appearance
            failedAction.backgroundColor = UIColor.redColor()
            failedAction.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
            return [failedAction]
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = SwipeExpansionStyle.selection
        options.transitionStyle = .border
        if orientation == .left {
            options.backgroundColor = UIColor.greenColor()
        } else {
            options.backgroundColor = UIColor.redColor()

        }
        return options
    }
}
