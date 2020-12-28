//
//  LikesApi.swift
//  Targeter
//
//  Created by Alexander Kolbin on 12/24/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation
import FirebaseDatabase

class LikesApi {
    let likesRef = Database.database().reference().child(Constants.RootFolders.likes)
    
    func saveLikeToDatabase(targetId: String, userId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        
    }
}
