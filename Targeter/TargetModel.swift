//
//  TargetModel.swift
//  Targeter
//
//  Created by Apple User on 1/6/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation

class TargetModel {
    var title: String?
    var imageURLString: String?
    var start: Int?
    var id: String?
    var timestamp: Int?
}
extension TargetModel {    
    static func transformDataToTarget(dict: [String:Any], id: String) -> TargetModel {
        let target = TargetModel()
        
        target.title = dict[Constants.Target.Title] as? String
        target.imageURLString = dict[Constants.Target.ImageUrlString] as? String
        target.start = dict[Constants.Target.Start] as? Int
        target.id = id
        target.timestamp = dict[Constants.Target.Timestamp] as? Int
        
        return target
    }
}
