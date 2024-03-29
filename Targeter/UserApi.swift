//
//  UserApi.swift
//  Targeter
//
//  Created by Apple User on 12/6/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UserApi {
    
    var usersRef = Database.database().reference().child(Constants.RootFolders.Users)
    var currentUser: User? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        return nil
    }
    
    func queryUsers(withText text: String, completion: @escaping (UserModel) -> Void) {
        usersRef.queryOrdered(byChild: Constants.UserData.UsernameLowercased).queryStarting(atValue: text).queryEnding(atValue: text + "\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value) { (snapshot) in
            snapshot.children.forEach({ (snapshotChild) in
                guard let child = snapshotChild as? DataSnapshot else {
                    return
                }
                if let dict = child.value as? [String: Any] {
                    let user = UserModel.transformDataToUser(dict: dict, id: child.key)
                    completion(user)
                }
            })
        }
    }
  
    
    func singleObserveCurrentUser(completion: @escaping (UserModel) -> Void,onError: @escaping (String) -> Void ){
        guard let userId = currentUser?.uid else {
            return
        }
        singleObserveUser(withUid: userId, completion: completion, onError: onError)
    }
    
    func singleObserveUser(withUid uid: String, completion: @escaping (UserModel) -> Void, onError: @escaping (String) -> Void) {
        usersRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
           // print(snapshot.value)
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformDataToUser(dict: dict, id: snapshot.key)
                completion(user)
            } else {
                onError("No userdata found")
            }
        }
    }
    
    func singleObserveUser(withUsername username: String, completion: @escaping (UserModel) -> Void, onError: @escaping (String) -> Void)  {
        let queryUsername = username.lowercased().trimmingCharacters(in: .whitespaces)
        usersRef.queryOrdered(byChild: Constants.UserData.UsernameLowercased).queryEqual(toValue: queryUsername).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                onError("No userdata found")
            } else {
                if let dict = snapshot.value as? [String: Any] {
                    let user = UserModel.transformDataToUser(dict: dict, id: snapshot.key)
                    completion(user)
                } else {
                    onError("No userdata found")
                }
            }
            
        }
    }
    
    
    func uploadProfileToServer(image: UIImage?, oldImageUrlString: String?, name: String?, location: String?, userId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        
        if let targetImageData = image?.jpegData(compressionQuality: 0.5) {
            uploadImageToServer(imageData: targetImageData, onSuccess: { (imageUrlString) in
                
                self.saveProfileDataToDatabase(imageUrlString: imageUrlString, name: name, location: location, userId: userId, onSuccess: {
                    
                    if let oldImageUrlString = oldImageUrlString {
                        let storageRef = Storage.storage().reference(forURL: oldImageUrlString)
                        storageRef.delete { error in
                            if let error = error {
                                print(error)
                            } else {
                                onSuccess()
                            }
                        }
                    }
                    onSuccess()
                }) { (error) in
                    onError(error)
                }
                    }, onError: onError)
        } else {
            self.saveProfileDataToDatabase(imageUrlString: nil, name: name, location: location, userId: userId, onSuccess: {
                onSuccess()
            }) { (error) in
                onError(error)
            }
        }
        
    }
    
    
    
    fileprivate func uploadImageToServer(imageData: Data, onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        let photoID = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child(Constants.RootFolders.Users).child(photoID)
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
    
    fileprivate func saveProfileDataToDatabase(imageUrlString: String?, name: String?, location: String?, userId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void){
        
        var dict: [String: String] = [:]
        let userRef = usersRef.child(userId)
        if imageUrlString != nil {
            dict[Constants.UserData.ImageURL] = imageUrlString!
        }
        if name != nil {
            dict[Constants.UserData.Name] = name!
        }
        if location != nil {
            dict[Constants.UserData.Location] = location!
        }
        
        
        userRef.updateChildValues(dict){ (error, ref) in
            if let error = error {
                onError(error.localizedDescription)
                return
            } else {
                onSuccess()
            }
        }
    }
    
    func increaseTargetsCount(onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        if let userId = currentUser?.uid {
            singleObserveUser(withUid: userId, completion: { (user) in
                var newTargetsCount: Int!
                if let targetsCount = user.targetsCount {
                    newTargetsCount = targetsCount + 1
                    self.usersRef.child(userId).updateChildValues([Constants.UserData.TargetsCount : newTargetsCount]){ (error, ref) in
                        if let error = error {
                            onError(error.localizedDescription)
                            return
                        } else {
                            onSuccess()
                        }
                    }
                } else {
                    newTargetsCount = 1
                    self.usersRef.child(userId).updateChildValues([Constants.UserData.TargetsCount : newTargetsCount]){ (error, ref) in
                        if let error = error {
                            onError(error.localizedDescription)
                            return
                        } else {
                            onSuccess()
                        }
                    }
                }
            }) { (error) in
                 onError(error)
            }
        }
    }
    
    func increaseFollowers(forUserId id: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let ref = Api.user.usersRef.child(id)
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var user = currentData.value as? [String : AnyObject] {
                var followers = user[Constants.Follow.Followers] as? Int ?? 0
               
                followers += 1
                
                user[Constants.Follow.Followers] = followers as AnyObject?
                
                // Set value and report transaction success
                currentData.value = user
                
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
    
    func decreaseFollowers(forUserId id: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let ref = Api.user.usersRef.child(id)
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var user = currentData.value as? [String : AnyObject] {
                var followers = user[Constants.Follow.Followers] as? Int ?? 0
               
                followers -= 1
                
                user[Constants.Follow.Followers] = followers as AnyObject?
                
                // Set value and report transaction success
                currentData.value = user
                
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
    
    func increaseFollowing(onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let ref = Api.user.usersRef.child(Api.user.currentUser!.uid)
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var user = currentData.value as? [String : AnyObject] {
                var following = user[Constants.Follow.Following] as? Int ?? 0
               
                following += 1
                
                user[Constants.Follow.Following] = following as AnyObject?
                
                // Set value and report transaction success
                currentData.value = user
                
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
    
    func decreaseFollowing(onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let ref = Api.user.usersRef.child(Api.user.currentUser!.uid)
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var user = currentData.value as? [String : AnyObject] {
                var following = user[Constants.Follow.Following] as? Int ?? 0
               
                following -= 1
                
                user[Constants.Follow.Following] = following as AnyObject?
                
                // Set value and report transaction success
                currentData.value = user
                
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
    
    
}
