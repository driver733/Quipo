//
//  topCell.swift
//  Reviews
//
//  Created by Admin on 05/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit


class topCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeSincePosted: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
