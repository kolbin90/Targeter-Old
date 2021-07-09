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
    var checkInsRef = Database.database().reference().child(Constants.RootFolders.CheckIns)
    
    func observeTargets(completion: @escaping (TargetModel) -> Void,onError: @escaping (String) -> Void ){
        targetsRef.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                var target = TargetModel.transformDataToTarget(dict: dict, id: snapshot.key)
                
                self.getCheckIns(forTargetId: target.id!, completion: { (checkIns) in
                    target.checkIns = checkIns
                    completion(target)
                }, onError: onError)
            } else {
                onError("Snapshot error")
            }
        }
    }
    
    func getTarget(withTargetId targetId: String, completion: @escaping (TargetModel) -> Void,onError: @escaping (String) -> Void ) {
        targetsRef.child(targetId).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let target = TargetModel.transformDataToTarget(dict: dict, id: snapshot.key)
                if let uid = Api.user.currentUser?.uid {
                    Api.likes.isTagetLikedBy(userId: uid, targetId: target.id!) { isLiked in
                        target.isLiked = isLiked
                        self.getCheckIns(forTargetId: target.id!, completion: { (checkIns) in
                            target.checkIns = checkIns
                            completion(target)
                        }, onError: onError)
                    }
                } else {
                    onError("Login error")
                }
            } else {
                onError("Snapshot error")
            }
        }
    }

    
    
    fileprivate func getCheckIns(forTargetId id: String,completion: @escaping ([CheckInModel]) -> Void,onError: @escaping (String) -> Void ) {
        var checkIns = [CheckInModel]()
        checkInsRef.child(id)/*.queryOrdered(byChild: Constants.CheckIn.Timestamp).queryLimited(toLast: 16)*/.observeSingleEvent(of: .value) {(snapshot) in
            for child in snapshot.children {
                guard let child = child as? DataSnapshot else {
                    onError("Error")
                    return
                }
                if let dict = child.value as? [String: Any] {
                    checkIns.append(CheckInModel.transformDataToCheckIn(dict: dict, id: child.key))
                }
            }
            
            completion(checkIns)
        }
        
    }
    
    func uploadTargetToServer(image: UIImage, title: String, start: Int, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        guard let targetImageData = image.jpegData(compressionQuality: 0.3) else {
            onError("Failed uploading image to server")
            return
        }
        uploadImageToServer(imageData: targetImageData, onSuccess: { (imageUrlString) in
            self.saveTargetInfoToDatabase(imageUrlString: imageUrlString, title: title, start: start, onSuccess: {
                Api.user.increaseTargetsCount(onSuccess: onSuccess, onError: onError)
                onSuccess()
            }, onError: onError)
        }, onError: onError)
    }
    
    func saveCheckInToDatabase(result: String, targetId: String, onSuccess: @escaping (CheckInModel) -> Void, onError: @escaping (String) -> Void) {
        let timestamp = Int(Date().timeIntervalSince1970)
        var dict = [Constants.CheckIn.Result: result, Constants.CheckIn.Timestamp: timestamp] as [String : Any]
        let checkInId = checkInsRef.child(targetId).childByAutoId().key!
        let checkIn = CheckInModel.transformDataToCheckIn(dict: dict, id: checkInId)
        checkInsRef.child(targetId).child(checkInId).setValue(dict) { (error, ref) in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            self.updateTargetStatus(targetId: targetId, lastAction: "Checked In", lastActionTimestamp: timestamp) {
                onSuccess(checkIn)
            } onError: { (error) in
                onError(error)
            }

        }
    }
    
    func deleteCheckInFromDatabase(targetId: String, checkInId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let timestamp = Int(Date().timeIntervalSince1970)
        checkInsRef.child(targetId).child(checkInId).removeValue { (error, ref) in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            self.updateTargetStatus(targetId: targetId, lastAction: "Removed check in", lastActionTimestamp: timestamp) {
                onSuccess()
            } onError: { (error) in
                onError(error)
            }
        }
    }
    
    func increaseCommentsCount(forTarget targetId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let ref = Api.target.targetsRef.child(targetId)
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var target = currentData.value as? [String : AnyObject] {
                var commentsCount = target[Constants.Target.commentsCount] as? Int ?? 0
               
                commentsCount += 1
                
                target[Constants.Target.commentsCount] = commentsCount as AnyObject?
                
                // Set value and report transaction success
                currentData.value = target
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            onSuccess()
        }
    }
    
    fileprivate func updateTargetStatus(targetId: String, lastAction: String, lastActionTimestamp: Int, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        
        let targetRef = targetsRef.child(targetId)
        let dict = [Constants.Target.LastAction: lastAction, Constants.Target.LastActionTimestamp: lastActionTimestamp] as [String : Any]
        targetRef.updateChildValues(dict) { (error, ref) in
            if let error = error {
                onError(error.localizedDescription)
            } else {
                onSuccess()
            }
        }
            
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
    
    fileprivate func saveTargetInfoToDatabase(imageUrlString: String, title: String, start: Int, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void){
        
        let timestamp = Int(Date().timeIntervalSince1970)
        guard let uid = Api.user.currentUser?.uid else {
            return
        }
        guard let newTargetId = Api.target.targetsRef.childByAutoId().key else {
            return
        }
        
        let newTargetRef = Api.target.targetsRef.child(newTargetId)
        
        var dict = [Constants.Target.ImageUrlString: imageUrlString, Constants.Target.Title: title,Constants.Target.Start: start,Constants.Target.Uid: uid, Constants.Target.Timestamp: timestamp, Constants.Target.LastAction: "Created target", Constants.Target.LastActionTimestamp: timestamp] as [String : Any]
        
        newTargetRef.setValue(dict) { (error, ref) in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            Api.user_target.saveUserTargetReference(targetId: newTargetId, onSuccess: onSuccess, onError: onError)
            Api.feed.addNewTargetToFeed(withTargetId: newTargetId, userId: uid)
        }
    }
}
