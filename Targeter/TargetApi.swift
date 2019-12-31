//
//  TargetApi.swift
//  Targeter
//
//  Created by Apple User on 12/30/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class TargetApi {
    var targetsRef = Database.database().reference().child(Constants.RootFolders.NewTargets)
    
    func uploadTargetToServer(image: UIImage, title: String, start: Int, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        guard let targetImageData = image.jpegData(compressionQuality: 0.3) else {
            onError("Failed uploading image to server")
            return
        }
        uploadImageToServer(imageData: targetImageData, onSuccess: { (imageUrlString) in
            self.savePostInfoToDatabase(imageUrlString: imageUrlString, title: title, start: start, onSuccess: {
                onSuccess()
            }, onError: onError)
        }, onError: onError)
    }
    

    fileprivate func uploadImageToServer(imageData: Data, onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        let photoID = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child(Constants.RootFolders.NewTargets).child(photoID)
        let profileImgMetadata = StorageMetadata()
        profileImgMetadata.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: profileImgMetadata, completion: { (metadata, error) in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            storageRef.downloadURL(completion: { (profileImgUrl, error) in
                guard error == nil else {
                    onError(error!.localizedDescription)
                    return
                }
                guard let profileImgUrlString = profileImgUrl?.absoluteString else {
                    onError("Failed uploading image to server")
                    return
                }
                onSuccess(profileImgUrlString)
                
            })
        })
    }
    
    fileprivate func savePostInfoToDatabase(imageUrlString: String, title: String, start: Int, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void){
        
        let timestamp = Int(Date().timeIntervalSince1970)
        guard let uid = Api.user.currentUser?.uid else {
            return
        }
        guard let newTargetId = Api.target.targetsRef.childByAutoId().key else {
            return
        }
        
//        Api.feed.REF_FEED.child(Api.user.CURRENT_USER!.uid).child(newPostId).setValue(true)
//        Api.follow.REF_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
//            let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
//            arraySnapshot.forEach({ (child) in
//                Api.feed.REF_FEED.child(child.key).updateChildValues([newPostId: true])
//                Api.notification.REF_NOTIFICATION.child(child.key).childByAutoId().setValue(["from": uid, "type": "feed", "objectId": newPostId, "timestamp": timestamp])
//            })
//        }
        
        let newTargerRef = Api.target.targetsRef.child(newTargetId)
        
        var dict = [Constants.Target.ImageUrlString: imageUrlString, Constants.Target.Title: title,Constants.Target.Start: start,Constants.Target.Uid: uid, Constants.Target.Timestamp: timestamp] as [String : Any]
        
        newTargerRef.setValue(dict) { (error, ref) in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            Api.user_target.user_targetRef.child(uid).child(newTargetId).setValue(true, withCompletionBlock: { (error, ref) in
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }
                onSuccess()
            })
        }
    }
}
