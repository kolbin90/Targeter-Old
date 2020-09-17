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

    @IBOutlet weak var profileCell: ProfileCell!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Variables
    var targets: [TargetModel] = []
    var userId: String?
    var name = ""
    var location = ""
    var profileImageUrlString = ""
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController(largeTitleDisplayMode: .always)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NewTargetCell", bundle: nil), forCellReuseIdentifier: "NewTargetCell")
//        Check if there is a user ID. If there is none, it means it's Users own profile
        if let userId = userId  {
            getUser(withID: userId)
        } else {
            guard let userId = Api.user.currentUser?.uid else {
                return
            }
            getUser(withID: userId)
        }
//        guard let userId = userId else {
////          If ita uaer's own profile then get userID and then gwt user info and targets for this ID
//            //observeTargets() // REPLACE TO getUser(withID)
//            return
//
//        }
//        If uaerID not nil, it means it was profided by another VC and we are going to use it
        
        
    }
    
    deinit {
        // Stop observing targets
    }
    
    // MARK: Assist methods
    
//    observe target changes in real time
    func observeTargetsForUser(withID id: String) {
        Api.user_target.getTargetsIdForUser(withID: id) { (targetId) in
            Api.target.getTarget(withTargetId: targetId, completion: { (target) in
                self.targets.append(target)
                self.tableView.reloadData()
            }) { (error) in
                ProgressHUD.showError(error)
            }
        }
    }
    
    func getUser(withID userid: String) {
        fillProfileData()
        observeTargetsForUser(withID: userid) // REPLACE WITH observeTargets for UserID
    }
    
    func fillProfileData() {
        Api.user.singleObserveCurrentUser(completion: { (user) in
            if let uaername = user.username {
                self.navigationItem.title = uaername
            }
            if let name = user.name {
                self.name = " \(name) "
            }
            if let location = user.location {
                self.location = " \(location) "
            }
            
            if let profileImageUrlString = user.imageURLString {
                self.profileImageUrlString = profileImageUrlString
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            ProgressHUD.showError(error)
        }
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
        cell.nameLabel.text = name
        cell.locationLabel.text = location
        cell.profileImageView.sd_setImage(with: URL(string: profileImageUrlString)) { (image, error, cacheType, url) in
            // TODO: Save image to core data
        }
        
        return cell.contentView
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UIScreen.main.bounds.width + 64
    }
    
}


