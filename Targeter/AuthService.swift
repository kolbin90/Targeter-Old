//
//  AuthService.swift
//  Targeter
//
//  Created by Apple User on 12/5/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class AuthService {

    static func getUserInfoDictionaryFromFacebook(completion: @escaping  ([String: Any]) -> Void) {
        let graphRequestConnection = FBSDKGraphRequestConnection()
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, name, picture.type(large)"], tokenString: FBSDKAccessToken.current().tokenString, version: FBSDKSettings.graphAPIVersion(), httpMethod: "GET")
        graphRequestConnection.add(graphRequest) { (requestConnection, data, error) in
            
            if let dict = data as? [String: Any] {
                completion(dict)
            }
        }
        graphRequestConnection.start()
    }
    
    static func saveNewUserInfo(profileImageUrl: String, name: String, username: String) {
        let storageRef = Storage.storage().reference()
        let databaseRef = Database.database().reference()
        let imagePath = "users/" + Auth.auth().currentUser!.uid + "/profileImage/\(Date())"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.child(imagePath).putFile(from: URL(string: profileImageUrl)!, metadata: metadata, completion: { (metadata, error) in
            guard (error == nil) else {
                print("error saving image to storage")
                return
            }
            
            let imageURL = storageRef.child((metadata?.path)!).description
            
            //databaseRef.child("users/\(self.userID!)/\(Constants.UserData.ImageURL)").setValue(imageURL)
            databaseRef.child("users").child(Auth.auth().currentUser!.uid).child(Constants.UserData.ImageURL).setValue(imageURL)
        })
        
    }
    
}
