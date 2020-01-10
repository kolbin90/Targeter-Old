//
//  User_TargetApi.swift
//  Targeter
//
//  Created by Apple User on 12/30/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import Foundation
//import FirebaseAuth
import FirebaseDatabase


class User_TargetApi {
    let user_targetRef = Database.database().reference().child(Constants.RootFolders.User_Target)
    
    func saveUserTargetReference(targetId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        if let uid = Api.user.currentUser?.uid {
            user_targetRef.child(Api.user.currentUser!.uid).child(targetId).setValue(true){ (error, ref) in
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }
                
            }
        }
    }
}


