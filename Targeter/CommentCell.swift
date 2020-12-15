//
//  CommentCell.swift
//  Targeter
//
//  Created by Alexander Kolbin on 12/9/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

protocol CommentCellDelegate {
    func goToProfileUserVC(withUser user: UserModel)
}

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
//    var delegate: CommentCellDelegate?
    var comment: CommentModel? {
        didSet {
            updateView()
        }
    }
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    var delegate: CommentCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "placeholderImg")
        usernameLabel.text = ""
        commentLabel.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        usernameLabel.text = ""
        commentLabel.text = ""
        profileImageView.layer.cornerRadius = 13
        let tapGestureForUsername = UITapGestureRecognizer(target: self, action: #selector(self.user_TchUpIns))
        usernameLabel.addGestureRecognizer(tapGestureForUsername)
        usernameLabel.isUserInteractionEnabled = true
        let tapGestureForProfileImage = UITapGestureRecognizer(target: self, action: #selector(self.user_TchUpIns))
        profileImageView.addGestureRecognizer(tapGestureForProfileImage)
        profileImageView.isUserInteractionEnabled = true
        
    }
    
    @objc func user_TchUpIns() {
        if let user = user {
            delegate?.goToProfileUserVC(withUser: user)
        }
    }

    func updateView() {
        commentLabel.text = comment?.commentText
        if let timestamp = comment?.timestamp {
            let now = Date()
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth, .month, .year])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            
            if let second = diff.second, second <= 0, let minute = diff.minute, minute == 0 {
                timeText = "Now"
            }
            if let second = diff.second, second > 0, let minute = diff.minute, minute == 0  {
                timeText = (second == 1) ? "\(second) second ago" : "\(second) seconds ago"
            }
            if let minute = diff.minute, minute > 0, let hour = diff.hour, hour == 0 {
                timeText = (minute == 1) ? "\(minute) minute ago" : "\(minute) minutes ago"
            }
            if let hour = diff.hour, hour > 0, let day = diff.day, day == 0 {
                timeText = (hour == 1) ? "\(hour) hour ago" : "\(hour) hours ago"
            }
            if let day = diff.day, day > 0, let week = diff.weekOfMonth, week == 0 {
                timeText = (day == 1) ? "\(day) day ago" : "\(day) days ago"
            }
            
            if let week = diff.weekOfMonth, week > 0, let month = diff.month, month == 0 {
                timeText = (week == 1) ? "\(week) week ago" : "\(week) weeks ago"
            }
            if let month = diff.month, month > 0, let year = diff.year, year == 0 {
                timeText = (month == 1) ? "\(month) month ago" : "\(month) monthes ago"
            }
            if let year = diff.year, year > 0{
                timeText = (year == 1) ? "\(year) year ago" : "\(year) years ago"
            }
            
            timestampLabel.text = timeText
        }
    }
    
    func setupUserInfo() {
        if let profileUrlString = user?.imageURLString {
            let profileUrl = URL(string: profileUrlString)
            profileImageView.sd_setImage(with: profileUrl, placeholderImage: UIImage(named: "placeholderImg"), options: [], completed: nil)
        }
        usernameLabel.text = user?.username
    }
    
}
