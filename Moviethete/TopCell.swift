//
//  TopCell.swift
//  Reviews
//
//  Created by Mikhail Yakushin on 05/07/15.
//  Copyright (c) 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit


class TopCell: UITableViewCell {

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
  
  override func prepareForReuse() {
    super.prepareForReuse()
    profileImage.sd_cancelCurrentImageLoad()
    profileImage.image = nil
    userName.text = nil
    timeSincePosted.text = nil
  }

}
