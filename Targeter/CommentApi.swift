//
//  CommentApi.swift
//  Targeter
//
//  Created by Alexander Kolbin on 12/9/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CommentApi {
    let commentRef = Database.database().reference().child(Constants.Comment.Comments)
    
    func observeComment(withCommentId id: String, completion: @escaping (CommentModel) -> Void) {
        commentRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String:Any] {
                let comment = CommentModel.transformToImagePost(dict: dict)
            completion(comment)
            }
        }
    }
    
    func saveCommentToDatabase(targetId: String, commentText: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        guard let newCommentId = Api.comment.commentRef.childByAutoId().key else {
            return
        }
        let newCommentRef = Api.comment.commentRef.child(newCommentId)
        guard let uid = Api.user.currentUser?.uid else {
            onError("Couldn't get user onfo")
            return
        }
        newCommentRef.setValue([Constants.Comment.CommentText: commentText,Constants.Comment.Uid: uid]) { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            }
            Api.target_comment.target_commentsRef.child(targetId).child(newCommentId).setValue(true, withCompletionBlock: { (error, ref) in
                if let error = error {
                    onError(error.localizedDescription)
                } else {
                    onSuccess()
                }
            })
            
//            let words = self.commentTextField.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
//            for var word in words {
//                if word.hasPrefix("#") {
//                    word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
//                    let newHashtagRef = Api.hashtag.REF_HASHTAG.child(word.lowercased())
//                    newHashtagRef.updateChildValues([self.postId!: true], withCompletionBlock: { (error, ref) in
//                        print(error)
//                        print(ref)
//                    })  //([self.postId: true])
//                }
//            }

            

            
        }
    }
}
