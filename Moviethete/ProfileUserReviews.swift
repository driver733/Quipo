//
//  ProfileUserReviews.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 25/07/15.
//  Copyright (c) 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit

class ProfileUserReviews: UITableViewCell {

    @IBOutlet weak var userReview: UILabel!
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
