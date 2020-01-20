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
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up Navigation controller
        setNavigationController(largeTitleDisplayMode: .never)


        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    // MARK: Actions
    @IBAction func editButton_TchUpIns(_ sender: Any) {
    }
}

// MARK: - Extensions
// MARK: UITableViewDataSource, UITableViewDelegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! UITableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

}
