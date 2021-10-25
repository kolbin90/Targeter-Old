//
//  TargetsViewController.swift
//  Targeter
//
//  Created by Apple User on 12/28/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit
import SwipeCellKit
// MARK: - TargetsViewControllerDelegate
protocol TargetsViewControllerDelegate {
    func cellSwiped(withResult result: CheckInModel.CheckInResult, for checkIn: CheckInModel?)
}

// MARK: - TargetsViewController

class TargetsViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var targets: [TargetModel] = []
    var delegates = [String: TargetsViewControllerDelegate]()
    var currentUserId: String!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationController(largeTitleDisplayMode: .never)

        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CheckInCell", bundle: nil), forCellReuseIdentifier: "CheckInCell")
        
        configureAuth()
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
    
    func observeTargetsForCurrentUser() {
        guard let userId = Api.user.currentUser?.uid else {
            return
        }
        currentUserId = userId
        Api.user_target.getTargetsIdForUser(withID: userId) { (targetId) in
            Api.target.getTarget(withTargetId: targetId, completion: { (target) in
                self.targets.append(target)
                self.tableView.reloadData()
            }) { (error) in
                ProgressHUD.showError(error)
            }
        }
    }
    
    func configureAuth() {
        AuthService.listenToAuthChanges { auth, user in
            if let activeUser = user {
                self.observeTargetsForCurrentUser()
            } else {
                self.targets = []
                Api.user_target.stopObservingTargetsIdForUser(withId: self.currentUserId)
            }
        }
    }
    
    // MARK: Actions
    @IBAction func addTargetButton_TchUpIns(_ sender: Any) {
        // set in storyboard
    }
    
}
// MARK: - Extensions
// MARK: UITableViewDataSource, UITableViewDelegate
extension TargetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckInCell", for: indexPath) as! NewTargetCell
        cell.cellTarget = targets[indexPath.row]
        cell.delegate = self
        delegates["\(indexPath.row)"] = cell
        
        return cell
        
    }
    
}
// MARK: SwipeTableViewCellDelegate
extension TargetsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if let checkInResult = (tableView.cellForRow(at: indexPath) as! NewTargetCell).todaysCheckInResult, checkInResult == .noResult {
            if orientation == .left  {
                let succeedAction = SwipeAction(style: .default, title: "Succeed") { action, indexPath in
                    // handle action by updating model with deletion
                    guard let targetId = self.targets[indexPath.row].id else {
                        return
                    }
                    Api.target.saveCheckInToDatabase(result: Constants.CheckIn.SucceedResult, targetId: targetId, onSuccess: { (checkIn) in
                        self.targets[indexPath.row].checkIns?.append(checkIn)
                        if let delegate = self.delegates["\(indexPath.row)"] {
                            delegate.cellSwiped(withResult: .succeed, for: checkIn)
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
                    Api.target.saveCheckInToDatabase(result: Constants.CheckIn.FailedResult, targetId: targetId, onSuccess: {(checkIn) in
                        self.targets[indexPath.row].checkIns?.append(checkIn)
                        if let delegate = self.delegates["\(indexPath.row)"] {
                            delegate.cellSwiped(withResult: .failed, for: checkIn)
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
        } else {
            let undoAction = SwipeAction(style: .default, title: "Undo") { action, indexPath in
                // handle action by updating model with deletion
                guard let targetId = self.targets[indexPath.row].id else {
                    return
                }
                if let todayCheckIn = (tableView.cellForRow(at: indexPath) as! NewTargetCell).todaysCheckIn, let checkInsId = todayCheckIn.id  {
                    Api.target.deleteCheckInFromDatabase(targetId: targetId, checkInId: checkInsId, onSuccess: {
                        guard let _ = self.targets[indexPath.row].checkIns else {
                            return
                        }
                        for (index, checkIn) in self.targets[indexPath.row].checkIns!.enumerated()  {
                            if checkIn.id == checkInsId {
                                self.targets[indexPath.row].checkIns!.remove(at: index)
                                break
                            }
                        }
                        if let delegate = self.delegates["\(indexPath.row)"] {
                            delegate.cellSwiped(withResult: .noResult, for: nil)
                        }
                    }, onError: { (error) in
                        ProgressHUD.showError(error)
                    })
                }
            }
            
            // customize the action appearance
            undoAction.backgroundColor = .gray
            undoAction.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
            return [undoAction]
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = SwipeExpansionStyle.selection
        options.transitionStyle = .border
        if let checkInResult = (tableView.cellForRow(at: indexPath) as! NewTargetCell).todaysCheckInResult, checkInResult == .noResult {
            if orientation == .left {
                options.backgroundColor = UIColor.greenColor()
            } else {
                options.backgroundColor = UIColor.redColor()
            }
        } else {
            options.backgroundColor = .gray
        }
        return options
    }
}
