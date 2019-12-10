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
                let user = UserModel.transformDataToUser(dict: dict)
                completion(user)
            } else {
                onError("No userdata found")
            }
        }
    }
    
    func singleObserveUser(withUsername username: String, completion: @escaping (UserModel) -> Void, onError: @escaping (String) -> Void)  {
        usersRef.queryOrdered(byChild: Constants.UserData.UsernameLowercased).queryEqual(toValue: username.lowercased()).observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot.value)
            snapshot.children.forEach({ (snapshotChild) in
                guard let child = snapshotChild as? DataSnapshot else {
                    return
                }
                if let dict = child.value as? [String: Any] {
                    //let user = UserModel.transformToUser(dict: dict, key: child.key)
                    //completion(user)
                }
            })
        }
    }
}
