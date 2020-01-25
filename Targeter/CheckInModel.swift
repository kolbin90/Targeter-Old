//
//  CheckInModel.swift
//  Targeter
//
//  Created by Apple User on 1/15/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation

class CheckInModel {
    var result: String?
    var timestamp: Int?
}

extension CheckInModel {
    static func transformDataToCheckIn(dict: [String:Any], id: String) -> CheckInModel {
        
        let checkIn = CheckInModel()
        checkIn.result = dict[Constants.CheckIn.Result] as? String
        checkIn.timestamp = dict[Constants.CheckIn.Timestamp] as? Int

        return checkIn
    }
    
    enum CheckInResult {
        case succeed
        case failed
        case noResult
    }
}
