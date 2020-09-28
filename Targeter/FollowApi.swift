//
//  FollowApi.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/25/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation
import FirebaseDatabase



class FollowApi {
    
    let followersRef = Database.database().reference().child(Constants.Follow.Followers)
    let followingRef = Database.database().reference().child(Constants.Follow.Following)
    
    func followAction(withUserId id: String) {
//        Api.user_posts.REF_USER_POSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
//            if let dict = snapshot.value as? [String: Any] {
//                for key in dict.keys {
//                    Database.database().reference().child("feed").child(Api.user.CURRENT_USER!.uid).child(key).setValue(true)
//                }
//            }
//        }
        Api.follow.followersRef.child(id).child(Api.user.currentUser!.uid).setValue(true)
        Api.follow.followingRef.child(Api.user.currentUser!.uid).child(id).setValue(true)
        Api.user.increaseFollowers(forUserId: id) {
        } onError: { (error) in
        }
        Api.user.increaseFollowing {
        } onError: { (error) in
        }


    }
    func unfollowAction(withUserId id: String) {
//        Api.user_posts.REF_USER_POSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
//            if let dict = snapshot.value as? [String: Any] {
//                for key in dict.keys {
//                    Database.database().reference().child("feed").child(Api.user.CURRENT_USER!.uid).child(key).removeValue()
//                }
//            }
//        }
        Api.follow.followersRef.child(id).child(Api.user.currentUser!.uid).setValue(NSNull())
        Api.follow.followingRef.child(Api.user.currentUser!.uid).child(id).setValue(NSNull())
        Api.user.decreaseFollowers(forUserId: id) {
        } onError: { (error) in
        }
        Api.user.decreaseFollowing {
        } onError: { (error) in
        }
    }
    
    func isFollowing(withUserId id: String, completed: @escaping (Bool) -> Void) {
        Api.follow.followersRef.child(id).child(Api.user.currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            } else {
                completed(true)
            }
        }
    }
}
