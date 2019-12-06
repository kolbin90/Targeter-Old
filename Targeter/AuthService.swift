//
//  AuthService.swift
//  Targeter
//
//  Created by Apple User on 12/5/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import Foundation
import FBSDKLoginKit


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
    
    static func saveNewUserInfo() {
        
    }

}
