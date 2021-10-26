
import UIKit

class FeedTableViewController: UITableViewController {

    
    var posts: [PostModel] = []
    var currentUserId: String!


    
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
        AuthService.listenToAuthChanges { auth, user in
            if let activeUser = user {
                guard let userId = Api.user.currentUser?.uid else {
                    return
                }
                self.currentUserId = userId
                Api.feed.observeFeed(forUid: Api.user.currentUser!.uid) { (post) in
                    self.posts.append(post)
                    self.tableView.reloadData()
                }
            } else {
                self.posts = []
                if let currentUserId = self.currentUserId {
                    Api.feed.stopObservingFeed(forId: currentUserId)
                }
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


extension FeedTableViewController: FeedCellDelegate {
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

extension FeedTableViewController: CommentsViewControllerDelegate {
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
    

