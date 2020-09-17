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
            print(snapshot.value)
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
    
    
    func uploadProfileToServer(image: UIImage?, name: String?, location: String?, userId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        
        if let targetImageData = image?.jpegData(compressionQuality: 0.5) {
            uploadImageToServer(imageData: targetImageData, onSuccess: { (imageUrlString) in
                
                self.saveProfileDataToDatabase(imageUrlString: imageUrlString, name: name, location: location, userId: userId, onSuccess: {
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
    
    
    
    
}
