//
//  Constants.swift
//  Targeter
//
//  Created by mac on 12/3/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation

struct Constants {
    struct UserData {
        static let Name = "name"
        static let City = "city"
        static let Age = "age"
        static let About = "about"
        static let ImageURL = "imageURL"
        static let Username = "username"
        static let UsernameLowercased = "username_lowercased"
        static let Percentage = "percentage"
        static let Email = "email"
    }
    struct Target {
        static let TargetID = "targetID"
        static let Title = "title"
        static let Description = "description"
        static let Percentage = "percentage"
        static let Started = "started"
        static let Completed = "completed"
        static let ImageURL = "imageURL"
        static let Checkins = "checkins"
        static let DateBeginning = "dateBeginning"
        static let DateEnding = "dateEnding"
    }
    struct RootFolders {
        static let Users = "users"
        static let Targets = "targets"
        static let NewTargets = "newtargets"
    }
}
