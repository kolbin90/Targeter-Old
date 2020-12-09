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
//        Api.target.observeTargets { (target) in
//            Api.user.singleObserveUser(withUid: target.uid!) { (user) in
//                let post = PostModel()
//                post.target = target
//                post.user = user
//                self.posts.append(post)
//                self.tableView.reloadData()
//            } onError: { (error) in
//                ProgressHUD.showError(error)
//            }
//
//        } onError: { (error) in
//            ProgressHUD.showError(error)
//        }

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
        return cell
    }
}
