//
//  SearchProfileCell.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/23/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

class SearchProfileCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
