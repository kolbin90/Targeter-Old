//
//  LikesViewController.swift
//  Targeter
//
//  Created by Alexander Kolbin on 7/9/21.
//  Copyright © 2021 Alder. All rights reserved.
//

import Foundation
import UIKit

class LikesViewController: UIViewController  {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var targetId: String!
    var users = [UserModel]()
    var likes = [UsersLikeModel]()
//    var delegate: CommentsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController(largeTitleDisplayMode: .always)
//        navigationController?.navigationBar.tintColor = .black
        tableView.dataSource = self
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableView.automaticDimension
        
        loadLikes()
//        loadComments()
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        tapGesture.cancelsTouchesInView = false
//        tableView.addGestureRecognizer(tapGesture)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ : )), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ : )), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    
    
    
    
    
    
    func loadLikes() {
        Api.likes.getLikesFor(targetId: targetId) { like in
            self.fetchUser(uid: like.uid!) {
                self.likes.append(like)
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.user.singleObserveUser(withUid: uid) { (user) in
            self.users.append(user)
            completed()
        } onError: { (error) in
            
        }
    }
    
    
    
    
}

extension LikesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let like = likes[indexPath.row]
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikeCell", for: indexPath) as! LikeCell
        cell.like = like
        cell.user = user
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
}

extension LikesViewController: LikeCellDelegate {
    func goToProfileUserVC(withUser user: UserModel) {
        let otherProfileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        otherProfileVC.user = user
        navigationController?.show(otherProfileVC, sender: nil)
    }
}
