//
//  CustomCell.swift
//  Reviews
//
//  Created by Mikhail Yakushin on 02/07/15.
//  Copyright (c) 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
import HCSStarRatingView

class ContentCell: UITableViewCell {
    
  @IBOutlet weak var posterImage: UIImageView!
  @IBOutlet weak var reviewTitle: UILabel!
  @IBOutlet weak var reviewText: UITextView!
  @IBOutlet weak var rating: HCSStarRatingView!
  
  
    override func awakeFromNib() {
      super.awakeFromNib()
      reviewText.textContainer.lineFragmentPadding = 0
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
  override func prepareForReuse() {
    super.prepareForReuse()
    posterImage.sd_cancelCurrentImageLoad()
    posterImage.image = nil
  }

    
}
