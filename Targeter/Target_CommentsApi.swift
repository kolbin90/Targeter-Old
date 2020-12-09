//
//  Target_CommentsApi.swift
//  Targeter
//
//  Created by Alexander Kolbin on 12/9/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Target_CommentsApi {
    let target_commentsRef = Database.database().reference().child(Constants.Comment.target_comments)
    
    func observeTarget_Comments(withTargetId id: String, completion: @escaping (String) -> Void) {
        target_commentsRef.child(id).observe(.childAdded) { (snapshot) in
            completion(snapshot.key)
        }
    }
}
