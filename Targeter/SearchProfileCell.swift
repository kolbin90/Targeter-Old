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
        let tapGestureForCellView = UITapGestureRecognizer(target: self, action: #selector(self.cellView_TchUpIns))
        cellView.addGestureRecognizer(tapGestureForCellView)
        cellView.isUserInteractionEnabled = true
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
        }
        usernameLabel.text = user?.username
        
        if user!.id! == Api.user.currentUser?.uid {
            followButton.isHidden = true
        } else {
            
        }
        
        
//        if user!.isFollowing! {
//            configureUnfollowButton()
//        } else {
//            configureFollowButton()
//        }
    }
    
    
    @IBAction func followButton_TchUpIns(_ sender: Any) {
    }
    
    

}
