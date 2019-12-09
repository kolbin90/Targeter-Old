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
    
    func singleObserveCurrentUser(completion: @escaping (UserModel) -> Void){
        guard let userId = currentUser?.uid else {
            return
        }
        singleObserveUser(withUid: userId, completion: completion)
    }
    
    func singleObserveUser(withUid uid: String, completion: @escaping (UserModel) -> Void) {
        usersRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
           // print(snapshot.value)
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformDataToUser(dict: dict)
                completion(user)
            }
        }
    }
}
