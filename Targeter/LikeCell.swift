//
//  LikeCell.swift
//  Targeter
//
//  Created by Alexander Kolbin on 7/9/21.
//  Copyright © 2021 Alder. All rights reserved.
//

import Foundation

class LikeCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    
    
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    var like: UsersLikeModel? {
        didSet {
            if let likesCount = like?.likesCount {
                if likesCount > 1 {
                likesCountLabel.text = "\(likesCount) likes"
                } else {
                    likesCountLabel.text = "\(likesCount) like"
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "placeholderImg")
        usernameLabel.text = ""
        likesCountLabel.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        usernameLabel.text = ""
        likesCountLabel.text = ""
        profileImageView.layer.cornerRadius = 13
//        let tapGestureForUsername = UITapGestureRecognizer(target: self, action: #selector(self.user_TchUpIns))
//        usernameLabel.addGestureRecognizer(tapGestureForUsername)
//        usernameLabel.isUserInteractionEnabled = true
//        let tapGestureForProfileImage = UITapGestureRecognizer(target: self, action: #selector(self.user_TchUpIns))
//        profileImageView.addGestureRecognizer(tapGestureForProfileImage)
//        profileImageView.isUserInteractionEnabled = true
        
    }
    
    
    
    
    
    
    
    
    
    func setupUserInfo() {
        if let profileUrlString = user?.imageURLString {
            let profileUrl = URL(string: profileUrlString)
            profileImageView.sd_setImage(with: profileUrl, placeholderImage: UIImage(named: "placeholderImg"), options: [], completed: nil)
        }
        usernameLabel.text = user?.username
    }
}
