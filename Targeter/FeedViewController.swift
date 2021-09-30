//
//  FeedViewController.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/30/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var posts: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        // Do any additional setup after loading the view.
        Api.feed.observeFeed(forUid: Api.user.currentUser!.uid) { (post) in
            self.posts.append(post)
            self.tableView.reloadData()
        }
        setNavigationController(largeTitleDisplayMode: .always)
    }
    

    // MARK: - Navigation


}

extension FeedViewController:  UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        cell.cellPost = posts[indexPath.row]
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
}

extension FeedViewController: FeedCellDelegate {
    func goToProfileUserVC(withUser user: UserModel) {
        let profileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
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

extension FeedViewController: CommentsViewControllerDelegate {
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
    
