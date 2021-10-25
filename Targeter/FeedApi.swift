//
//  FeedApi.swift
//  Targeter
//
//  Created by Alexander Kolbin on 11/19/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FeedApi {
    let feedRef = Database.database().reference().child(Constants.RootFolders.Feed)
    
    func observeFeed(forUid id: String, completion: @escaping (PostModel) -> Void) {
        feedRef.child(id).observe(.childAdded) { (snapshot) in
            Api.target.getTarget(withTargetId: snapshot.key) { (target) in
                Api.user.singleObserveUser(withUid: target.uid!) { (user) in
                    let post = PostModel()
                    post.target = target
                    post.user = user
                    completion(post)
                } onError: { (error) in
                    ProgressHUD.showError(error)
                }
            } onError: { (error) in
                ProgressHUD.showError(error)
            }
        }
    }
    
    func stopObservingFeed(forId id: String) {
        feedRef.child(id).removeAllObservers()
    }
    
    func addNewTargetToFeed(withTargetId targetid: String, userId uid: String) {
        Api.follow.followersRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
            arraySnapshot.forEach({ (child) in
                Api.feed.feedRef.child(child.key).updateChildValues([targetid: true])
            })
        }
    }
    
    
    
}
