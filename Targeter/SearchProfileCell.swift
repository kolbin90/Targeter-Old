//
//  SearchProfileCell.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/23/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

protocol SearchProfileCellDelegate {
    func goToOtherProfileUserVC(withUser user: UserModel)
}

class SearchProfileCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var cellView: UIView!
    
    var delegate: SearchProfileCellDelegate?
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGestureForImageView = UITapGestureRecognizer(target: self, action: #selector(self.cellView_TchUpIns))
        profileImageView.addGestureRecognizer(tapGestureForImageView)
        profileImageView.isUserInteractionEnabled = true
        let tapGestureForLabel = UITapGestureRecognizer(target: self, action: #selector(self.cellView_TchUpIns))
        usernameLabel.addGestureRecognizer(tapGestureForLabel)
        usernameLabel.isUserInteractionEnabled = true
        
        profileImageView.layer.cornerRadius = 15
    }
    
    @objc func cellView_TchUpIns() {
        if let user = user {
            delegate?.goToOtherProfileUserVC(withUser: user)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = ""
        profileImageView.image = UIImage(named: "avatar-1577909_960_720")
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateView() {
        if let profileUrlString = user?.imageURLString {
            let profileUrl = URL(string: profileUrlString)
            profileImageView.sd_setImage(with: profileUrl, placeholderImage: UIImage(named: "avatar-1577909_960_720"), options: [], completed: nil)
        } else {
            profileImageView.image = UIImage(named: "avatar-1577909_960_720")
        }
        usernameLabel.text = user?.username
        
        if user!.id! == Api.user.currentUser?.uid {
            followButton.isHidden = true
        } else {
            
        }
        
        
        if user!.isFollowing! {
            configureUnfollowButton()
        } else {
            configureFollowButton()
        }
    }
    
    func configureFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.backgroundColor = UIColor(red: 69/255, green: 144/255, blue: 255/255, alpha: 1)
        followButton.setTitleColor(.white, for: .normal)
        
        followButton.setTitle("Follow", for: .normal)
        followButton.removeTarget(self, action:#selector(self.unfollowAction), for: UIControl.Event.touchUpInside)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControl.Event.touchUpInside)
    }
    
    func configureUnfollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.backgroundColor = .clear
        followButton.setTitleColor(.black, for: .normal)
        followButton.setTitle("Unfollow", for: .normal)
        followButton.removeTarget(self, action: #selector(self.followAction), for: UIControl.Event.touchUpInside)
        followButton.addTarget(self, action: #selector(self.unfollowAction), for: UIControl.Event.touchUpInside)
    }
    
    @objc func followAction() {
        Api.follow.followAction(withUserId: user!.id!)
        configureUnfollowButton()
        user!.isFollowing = true
    }
    
    @objc func unfollowAction() {
        Api.follow.unfollowAction(withUserId: user!.id!)
        configureFollowButton()
        user!.isFollowing = false
    }
    
    
    @IBAction func followButton_TchUpIns(_ sender: Any) {
    }
    
    

}
