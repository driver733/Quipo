//
//  ProfileSettingsFollowFriendsCell.swift
//  
//
//  Created by Mikhail Yakushin on 8/2/15.
//
//

import UIKit

class ProfileSettingsFollowFriendsCell: UITableViewCell {
    
  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var account: UILabel!
  
    override func awakeFromNib() {
      super.awakeFromNib()
      account.text = ""
    }

    override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      // Configure the view for the selected state
    }
  
  
  
    
}
