//
//  FeedViewController.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/30/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit
import FirebaseAuth

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var posts: [PostModel] = []

    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle! // Listens when Firebase Auth changed status
    var user: User?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        // Do any additional setup after loading the view.
        configureAuth()
        setNavigationController(largeTitleDisplayMode: .always)
    }
    

    // MARK: - Navigation
    
    func configureAuth() {
//        let provider = [FUIGoogleAuth()]
//        FUIAuth.defaultAuthUI()?.providers = provider
        
        // Create a listener to observe if auth status changed
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            if let activeUser = user {
                if self.user != activeUser {
                    self.user = activeUser
                    //                    self.signedInStatus(isSignedIn: true)
                    var name = ""
                    if let email = activeUser.email {
                        name = email.components(separatedBy: "@")[0]
                    }
                    //                    self.displayName = name
                    //                    self.userID = Auth.auth().currentUser?.uid
                    //                    self.downloadTargets()
                    Api.feed.observeFeed(forUid: Api.user.currentUser!.uid) { (post) in
                        self.posts.append(post)
                        self.tableView.reloadData()
                    }
                }
            } else {
                //                if let userID = self.userID {
                //                    self.databaseRef.child(Constants.RootFolders.Targets).child(userID).removeObserver(withHandle: self._refHandle)
                //                }
//                self.targets = []
//                self.tableView.reloadData()
//                self.userID = nil
//                self.signedInStatus(isSignedIn: false)
                self.posts = []
                self.loginSession()
            }
        }
    }
    
    func loginSession() {
        // Show auth view controller
//        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
//        self.present(authViewController, animated: true, completion: nil)
        
        let signInVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let signInNavController = UINavigationController(rootViewController: signInVC)
        signInNavController.modalPresentationStyle = .fullScreen
        self.present(signInNavController, animated: true, completion: nil)
    }


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
    
