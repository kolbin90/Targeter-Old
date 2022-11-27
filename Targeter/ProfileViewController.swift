//
//  ProfileViewController.swift
//  Targeter
//
//  Created by Apple User on 12/24/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import UIKit

// MARK: - ProfileViewController
class ProfileViewController: UITableViewController {

    // MARK: Outlets

 //   @IBOutlet weak var profileCell: ProfileCell!

    // MARK: Variables
    var targets: [TargetModel] = []
    var posts: [PostModel] = []
    var user: UserModel?
    var userId: String?
    var name = ""
    var location = ""
    var profileImageUrlString = ""
    var targetsCountString = ""
    var followers = ""
    var following = ""
    var newProfileImage: UIImage?
    var currentUserId: String!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController(largeTitleDisplayMode: .always)
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        configureAuth()
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
                self.targets.append(target)
                self.tableView.reloadData()
            }) { (error) in
                ProgressHUD.showError(error)
            }
        }
    }
    
    func getUser(withID userid: String) {
        
        Api.user.singleObserveCurrentUser { user in
            self.user = user
            self.fillProfileData()
        } onError: { error in
            ProgressHUD.showError(error)
        }

       // observeTargetsForUser(withID: userid) // REPLACE WITH observeTargets for UserID
    }
    
    func fillProfileData() {
        if let user = user {
            self.observeTargetsForUser(withID: user.id!)
            
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
 
    }
    
    func configureAuth() {
        // Create a listener to observe if auth status changed
        AuthService.listenToAuthChanges { auth, user in
            if let activeUser = user {
                guard let userId = Api.user.currentUser?.uid else {
                    return
                }
                self.currentUserId = userId
                self.getUser(withID: userId)
            } else {
                self.posts = []
                Api.user_target.stopObservingTargetsIdForUser(withId: self.currentUserId)
            }
        }
    }
    
    // MARK: Actions
    @IBAction func editButton_TchUpIns(_ sender: Any) {
        let editProfileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        editProfileVC.delegate = self
        self.navigationController?.show(editProfileVC, sender: nil)
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "NewTargetCell", for: indexPath) as! NewTargetCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        cell.cellPost = posts[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
//        cell.showArrows = false
//        cell.cellTarget = targets[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
        cell.targetsLabel.text = targetsCountString
        cell.nameLabel.layer.cornerRadius = 10
        cell.nameLabel.layer.masksToBounds = true
        cell.locationLabel.layer.cornerRadius = 10
        cell.locationLabel.layer.masksToBounds = true
        cell.profileImageView.layer.cornerRadius = 20
        cell.profileImageView.layer.masksToBounds = true
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
        cell.followersLabel.text = followers
        cell.followingLabel.text = following
        if let newProfileImage = newProfileImage {
            cell.profileImageView.image = newProfileImage
        } else {
            if profileImageUrlString != "" {
                cell.profileImageView.sd_setImage(with: URL(string: profileImageUrlString)) { (image, error, cacheType, url) in
                    // TODO: Save image to core data
                }
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

extension ProfileViewController: EditProfileViewControllerDelegate {
    func updateProfile(_ profileImage: UIImage?, _ name: String?, _ location: String?) {
        if let profileImage = profileImage {
            newProfileImage = profileImage
        }
        if let name = name {
            self.name = name
        }
        if let location = location {
            self.location = location
        }
        
        tableView.reloadData()
    }

}

extension ProfileViewController: FeedCellDelegate {
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

extension ProfileViewController: CommentsViewControllerDelegate {
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

