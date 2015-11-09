//
//  Reviewcell.swift
//  Moviethete
//
//  Created by Mike on 10/10/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import UIKit
import HCSStarRatingView

class ReviewCell: UITableViewCell {

  @IBOutlet weak var rating: HCSStarRatingView!
  @IBOutlet weak var reviewTitle: UILabel!
  @IBOutlet weak var reviewText: UITextView!
  @IBOutlet weak var comments: UIButton!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

