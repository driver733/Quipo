//
//  profile_topCell.swift
//  Moviethete
//
//  Created by Admin on 25/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

class profile_topCell: UITableViewCell {

 
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
    @IBOutlet weak var unknownView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        awaitedCount.font = UIFont(name: "Nanum Pen", size: awaitedCount.font.pointSize)
        favouriteCount.font = UIFont(name: "Nanum Pen", size: favouriteCount.font.pointSize)
        watchedCount.font = UIFont(name: "Nanum Pen", size: watchedCount.font.pointSize)
        followingCount.font = UIFont(name: "Nanum Pen", size: followingCount.font.pointSize)
        followersCount.font = UIFont(name: "Nanum Pen", size: followersCount.font.pointSize)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
