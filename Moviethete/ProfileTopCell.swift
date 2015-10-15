//
//  ProfileTopCell.swift
//  Moviethete
//
//  Created by Admin on 25/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

class ProfileTopCell: UITableViewCell {

 
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var watchedCount: UILabel!
    @IBOutlet weak var favouriteCount: UILabel!
    @IBOutlet weak var awaitedCount: UILabel!
    
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var awaitedView: UIView!
    @IBOutlet weak var favouriteView: UIView!
    @IBOutlet weak var watchedView: UIView!
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var userReviewsView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
