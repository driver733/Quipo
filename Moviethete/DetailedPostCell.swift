//
//  DetailedPostCell.swift
//  Moviethete
//
//  Created by Mike on 8/29/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import UIKit

class DetailedPostCell: UITableViewCell {

  @IBOutlet weak var posterImage: UIImageView!
  @IBOutlet weak var movieInfo: UITextView!
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
