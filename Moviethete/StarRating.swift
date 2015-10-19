//
//  StarRating.swift
//  Moviethete
//
//  Created by Mike on 9/3/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import UIKit
import HCSStarRatingView


extension UITableViewCell {
  
  func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
}

class StarRating: UITableViewCell {
  
  @IBOutlet weak var rating: HCSStarRatingView!

    override func awakeFromNib() {
      super.awakeFromNib()
     // rating.emptyStarImage = getImageWithColor(UIColor.blackColor(), size: CGSizeMake(50, 50))
      
  //    rating.filledStarImage = getImageWithColor(UIColor.greenColor(), size: CGSizeMake(50, 50))

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
