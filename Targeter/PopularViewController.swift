//
//  SearchViewController.swift
//  Targeter
//
//  Created by Alexander Kolbin on 11/29/21.
//  Copyright © 2021 Alder. All rights reserved.
//

import UIKit

class PopularViewController: UITableViewController {
    
    var posts: [PostModel] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        // Do any additional setup after loading the view.
        setNavigationController(largeTitleDisplayMode: .always)
        self.tableView.contentInset.bottom = self.tabBarController?.tabBar.frame.height ?? 0
        getPopularTargets()
    }
    
    func getPopularTargets() {
        Api.target.getPopularTargets { post in
            self.posts.insert(post, at: 0)
            self.tableView.reloadData()
            
        } onError: { error in
            ProgressHUD.showError(error)
        }

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        cell.cellPost = posts[indexPath.row]
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }

}


extension PopularViewController: FeedCellDelegate {
    func goToProfileUserVC(withUser user: UserModel) {
        let profileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        profileVC.user = user
        navigationController?.show(profileVC, sender: nil)
    }
    
    
    func updateLikes(withTargetId id: String, isLiked: Bool) {
        if let userId = Api.user.currentUser?.uid {
            Api.likes.updateUsersLikesFor(targetId: id, userId: userId, isLiked: isLiked) {
                 
            } onError: { error in
                ProgressHUD.showError(error)
            }

        }
    }
    
    func goToLikesVC(withTargetId id: String) {
        let likesVC = UIStoryboard.init(name: "Feed", bundle: nil).instantiateViewController(withIdentifier: "LikesViewController") as! LikesViewController
        likesVC.targetId = id
        self.navigationController?.show(likesVC, sender: self)
    }
    
    
    func goToCommentsVC(withTargetId id: String) {
        let commentsVC = UIStoryboard.init(name: "Feed", bundle: nil).instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        commentsVC.targetId = id
        commentsVC.delegate = self
        //editProfileVC.delegate = self
        self.navigationController?.show(commentsVC, sender: nil)
    }
}

extension PopularViewController: CommentsViewControllerDelegate {
    func increaseCommentsCount(newNumber: Int, targetId: String) {
        for post in  posts {
            if post.target.id == targetId {
                post.target.commentsCount = newNumber
                tableView.reloadData()
                return
            }
        }
    }
}
