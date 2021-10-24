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
            let manager = LoginManager()
            manager.logOut()
            try Auth.auth().signOut()
        } catch {
            print("unable to sign out: \(error)")
        }
    }
    
    static func getUserInfoDictionaryFromFacebook(completion: @escaping  ([String: Any]) -> Void) {
        let graphRequestConnection = GraphRequestConnection()
        guard let accessTokenString = AccessToken.current?.tokenString else {
            return
        }
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"email, name, picture.type(large)"], tokenString: accessTokenString, version: Settings.graphAPIVersion, httpMethod: HTTPMethod.get)
        graphRequestConnection.add(graphRequest) { (requestConnection, data, error) in
            
            if let dict = data as? [String: Any] {
                completion(dict)
            }
        }
        graphRequestConnection.start()
    }
    
    static func saveNewUserInfo(profileImageUrl: String?, name: String?, username: String?, email: String?) {
        let storageRef = Storage.storage().reference()
        let databaseRef = Database.database().reference()
        if let profileImageUrl = profileImageUrl {

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
        }
        // Save username and name to database
        if let username = username {
            databaseRef.child("users").child(Auth.auth().currentUser!.uid).child(Constants.UserData.Username).setValue(username)
            databaseRef.child("users").child(Auth.auth().currentUser!.uid).child(Constants.UserData.UsernameLowercased).setValue(username.lowercased())
        }
        if let name = name {
            databaseRef.child("users").child(Auth.auth().currentUser!.uid).child(Constants.UserData.Name).setValue(name)
        }
        if let email = email {
            Api.user.usersRef.child(Api.user.currentUser!.uid).child("email").setValue(email)
        }
    }
    
    static func isEmailUsed(email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: email) { (methods, error) in
            if  methods == nil {
                completion(false)
            } else {
                completion(true)
            }
        }
        
    }
    
    static func signUp(username:String, email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorString: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
            }
            saveNewUserInfo(profileImageUrl: nil, name: nil, username: username, email: email)
            onSuccess()
        }
    }
    
    static func signIn(email: String, password: String, OnSuccess: @escaping() -> Void, onError: @escaping(_ errorString: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            OnSuccess()
        }
    }
    
    static func signInAndLinkWithFacebook(email: String, password: String, facebookCredential: AuthCredential, OnSuccess: @escaping() -> Void, onError: @escaping(_ errorString: String?) -> Void) {
        signIn(email: email, password: password, OnSuccess: {
            Auth.auth().currentUser?.linkAndRetrieveData(with: facebookCredential, completion: { (result, error) in
                if error != nil {
                    onError(error!.localizedDescription)
                    return
                }
                if result != nil {
                    OnSuccess()
                }
            })
        }) { (error) in
            onError(error)
        }
        
    }
    
    static func sendPasswordReset(withEmail email: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
       
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            guard error == nil else {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    static func listenToAuthChanges(competion: @escaping (_ auth: Auth, _ user: User?) -> Void) {
        let _ = Auth.auth().addStateDidChangeListener({ auth, user in
            competion(auth, user)
        })
    }
    
}
