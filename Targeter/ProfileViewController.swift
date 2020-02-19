//
//  ProfileViewController.swift
//  Targeter
//
//  Created by Apple User on 12/24/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit

// MARK: - ProfileViewController
class ProfileViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var targetsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Variables
    var targets: [TargetModel] = []
    var userId: String?
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController(largeTitleDisplayMode: .never)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NewTargetCell", bundle: nil), forCellReuseIdentifier: "NewTargetCell")
        guard let userId = userId else {return}
        getUser(withID: userId)
        
    }
    
    deinit {
        // Stop observing targets
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
    
    func getUser(withID id: String) {
        observeTargets()
    }
    // MARK: Actions
    @IBAction func editButton_TchUpIns(_ sender: Any) {
    }
}

// MARK: - Extensions
// MARK: UITableViewDataSource, UITableViewDelegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewTargetCell", for: indexPath) as! NewTargetCell
        cell.showArrows = false
        cell.cellTarget = targets[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
        return cell.contentView
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UIScreen.main.bounds.width + 64
    }
    
}


