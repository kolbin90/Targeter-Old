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
import CoreData


class AuthService {
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack

    static func firebaseLogOut() {
        do {
            // Trying to sign out from Firebase
            let manager = FBSDKLoginManager()
            manager.logOut()
            try Auth.auth().signOut()
        } catch {
            print("unable to sign out: \(error)")
        }
    }
    
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
        
        // Download image from Facebook, Upload it to Firevase storage, save imageURL to database
        guard let url = URL(string: profileImageUrl) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { (data, responce, error) in
            guard error == nil else {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            guard let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                storageRef.child(imagePath).putData(data, metadata: metadata, completion: { (storageMetafata, error) in
                    guard (error == nil) else {
                        print("error saving image to storage")
                        return
                    }
                    
                    let imageURL = storageRef.child((storageMetafata?.path)!).description
                    databaseRef.child("users").child(Auth.auth().currentUser!.uid).updateChildValues([Constants.UserData.ImageURL:imageURL])  //child(Constants.UserData.ImageURL).setValue(imageURL)
                })
            }
            }.resume()
        // Save username and name to database
        databaseRef.child("users").child(Auth.auth().currentUser!.uid).child(Constants.UserData.Username).setValue(username)
        databaseRef.child("users").child(Auth.auth().currentUser!.uid).child(Constants.UserData.Name).setValue(name)
       
    }
    
}
