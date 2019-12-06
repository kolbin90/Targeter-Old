//
//  UserModel.swift
//  Targeter
//
//  Created by Apple User on 12/6/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import Foundation
class UserModel {
    var name: String?
    var imageURLString: String?
    var username: String?
    var email: String?
}
extension UserModel {
    static func transformFaceBookDataToUser(dict: [String:Any]) -> UserModel {
        let user = UserModel()
        user.email = dict["email"] as? String
        user.name = dict["name"] as? String
        if let pictureDictionary = dict["picture"] as? [String:Any] {
            print(pictureDictionary)
            if let dataDictionary = pictureDictionary["data"] as? [String:Any] {
                print(dataDictionary)
                if let imageURLString = dataDictionary["url"] as? String {
                user.imageURLString = imageURLString
                }
            }

        }
        //user.id = key
        return user
    }
}
