//
//  LikesApi.swift
//  Targeter
//
//  Created by Alexander Kolbin on 12/24/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation
import FirebaseDatabase

class LikesApi {
    let likesRef = Database.database().reference().child(Constants.RootFolders.likes)
    let targetsRef = Database.database().reference().child(Constants.RootFolders.Targets)
    
    func updateUsersLikesFor(targetId: String, userId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let timestamp = Int(Date().timeIntervalSince1970)
        likesRef.child(targetId).child(userId).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                
            }
        } withCancel: { (error) in
            onError(error.localizedDescription)
        }

    }
    
    func incrementLikes(targetId: String, todaysLikeExcists: Bool, onSuccess: @escaping (TargetModel) -> Void, onError: @escaping (String) -> Void) {
        targetsRef.child(targetId).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var target = currentData.value as? [String : AnyObject], let uid = Api.user.currentUser?.uid {
                var likeCount = target["likeCount"] as? Int ?? 0
                if todaysLikeExcists {
                    // Unstar the post and remove self from stars
                    likeCount -= 1
                } else {
                    // Star the post and add self to stars
                    likeCount += 1
                }
                target[Constants.Target.likesCount] = likeCount as AnyObject?
                
                // Set value and report transaction success
                currentData.value = target
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let target = TargetModel.transformDataToTarget(dict: dict, id: targetId)
                onSuccess(target)
            }
        }
    }
    
    func isTagetLikedBy(userId uid: String, targetId: String, result: @escaping (Bool) -> Void ) {
        likesRef.child(uid).observeSingleEvent(of: .value) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let like = UsersLikeModel.transformToLikeModel(dict: dict, uid: snapshot.key)
                if let timestamp = like.timestamp {
                    let dateFromTimestamp = Date(timeIntervalSince1970: Double(timestamp))
                    result(Calendar.current.isDate(Date(), inSameDayAs: dateFromTimestamp))
                }
            }
        }
    }
    
}
