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
//        commentLabel.handleHashtagTap { (word) in
//            print(word)
//            self.delegate?.goToHashtagVC(withHashtag: word)
//        }
//        commentLabel.handleMentionTap { (username) in
//            Api.user.observeUserByUsername(username: username, completion: { (user) in
//                self.delegate?.goToProfileUserVC(withUser: user)
//            })
//
//        }
    }
    
    func setupUserInfo() {
        if let profileUrlString = user?.imageURLString {
            let profileUrl = URL(string: profileUrlString)
            profileImageView.sd_setImage(with: profileUrl, placeholderImage: UIImage(named: "placeholderImg"), options: [], completed: nil)
        }
        usernameLabel.text = user?.username
    }
    
}
