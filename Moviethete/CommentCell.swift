//
//  CommentCell.swift
//  Moviethete
//
//  Created by Mike on 11/8/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
  
  @IBOutlet weak var profile: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var comment: UILabel!
  @IBOutlet weak var timeSincePosted: UILabel!
  
  
    override func awakeFromNib() {
      super.awakeFromNib()
      self.comment.lineBreakMode = .ByCharWrapping
      self.comment.numberOfLines = 0
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
