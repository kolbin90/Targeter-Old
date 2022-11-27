//
//  OtherProfileViewController.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/19/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation
import UIKit

// MARK: - ProfileViewController
class OtherProfileViewController: UITableViewController {

    // MARK: Outlets

    @IBOutlet weak var followButton: UIBarButtonItem!
    
    // MARK: Variables
    var targets: [TargetModel] = []
    var user: UserModel!
    var posts: [PostModel] = []
    var userId: String?
    var name = ""
    var location = ""
    var profileImageUrlString = ""
    var targetsCountString = ""
    var followers = ""
    var following = ""
    var newProfileImage: UIImage?
    var isFollowing = false
    var uId = ""
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController(largeTitleDisplayMode: .always)
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.register(UINib(nibName: "NewTargetCell", bundle: nil), forCellReuseIdentifier: "NewTargetCell")
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "FeedCell")

        
        fillProfileData()
        guard let _ = user.id else {
            ProgressHUD.showError()
            return
        }
        uId = user.id!
        guard let userId = Api.user.currentUser?.uid else {
            return
        }
        if userId == uId {
            self.navigationItem.rightBarButtonItem = nil
        }
        updateFollowingStatus()
        observeTargetsForUser(withID: uId)

        
//        Check if there is a user ID. If there is none, it means it's Users own profile
//        if let userId = userId  {
//            getUser(withID: userId)
//        } else {
//            guard let userId = Api.user.currentUser?.uid else {
//                return
//            }
//            getUser(withID: userId)
//        }
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
                let post = PostModel()
                post.target = target
                post.user = self.user
                self.posts.append(post)
//                self.targets.append(target)
                self.tableView.reloadData()
            }) { (error) in
                ProgressHUD.showError(error)
            }
        }
    }
    

    
    func fillProfileData() {
        if let uaername = user.username {
            self.navigationItem.title = uaername
        }
        if let name = user.name {
            self.name = name
        }
        if let location = user.location {
            self.location = location
        }
        
        if let profileImageUrlString = user.imageURLString {
            self.profileImageUrlString = profileImageUrlString
        }
        if let targetsCount = user.targetsCount {
            self.targetsCountString = String(targetsCount)
        } else {
            self.targetsCountString = "0"
        }
        
        if let followers = user.followers {
            self.followers = String(followers)
        } else {
            self.followers = "0"
        }
        
        if let following = user.following {
            self.following = String(following)
        } else {
            self.following = "0"
        }
        
        
        
        self.tableView.reloadData()
        
    }
    
    func isFollowing(withUserId id: String, completed: @escaping (Bool) -> Void) {
        Api.follow.isFollowing(withUserId: id, completed: completed)
    }
    
    func updateFollowingStatus() {
        isFollowing(withUserId: uId) { isFollowing in
            if isFollowing {
                self.navigationItem.rightBarButtonItem?.title = "Following"
                self.navigationItem.rightBarButtonItem?.tintColor = .black
            } else {
                self.navigationItem.rightBarButtonItem?.title = "Follow"
                self.navigationItem.rightBarButtonItem?.tintColor = .blue
            }
            self.isFollowing = isFollowing
        }
    }
    
    // MARK: Actions
    @IBAction func followButton_TchUpIns(_ sender: Any) {
        if isFollowing {
            Api.follow.unfollowAction(withUserId: uId)
            updateFollowingStatus()
        } else {
            Api.follow.followAction(withUserId: uId)
            updateFollowingStatus()
        }
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        cell.cellPost = posts[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
        cell.nameLabel.layer.cornerRadius = 10
        cell.nameLabel.layer.masksToBounds = true
        cell.locationLabel.layer.cornerRadius = 10
        cell.locationLabel.layer.masksToBounds = true
        cell.profileImageView.layer.cornerRadius = 20
        cell.profileImageView.layer.masksToBounds = true
        cell.targetsLabel.text = targetsCountString
        cell.followersLabel.text = followers
        cell.followingLabel.text = following
        if name != "" {
            cell.nameLabel.text = "  \(name)  "
        } else {
            cell.nameLabel.isHidden = true
        }
        
        if location != "" {
            cell.locationLabel.text = "  \(location)  "
        } else {
            cell.locationLabel.isHidden = true
        }
        if let newProfileImage = newProfileImage {
            cell.profileImageView.image = newProfileImage
        } else {
            cell.profileImageView.sd_setImage(with: URL(string: profileImageUrlString)) { (image, error, cacheType, url) in
                // TODO: Save image to core data
            }
        }
        
        return cell.contentView
    }

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UIScreen.main.bounds.width + 64
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 217
    }
    
}

// MARK: - Extensions


extension OtherProfileViewController: FeedCellDelegate {
    func goToTargetDetailsVC(withTargetId id: String) {
        
    }
    
    func goToProfileUserVC(withUser user: UserModel) {
        let otherProfileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        otherProfileVC.user = user
        navigationController?.show(otherProfileVC, sender: nil)
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

extension OtherProfileViewController: CommentsViewControllerDelegate {
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


