//
//  TrailersCell.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 11/3/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
import AVKit

class TrailersCell: UITableViewCell {


  @IBOutlet weak var thumbnail: UIImageView!
  @IBOutlet weak var topLabel: UILabel!
  @IBOutlet weak var videoType: UILabel!
  @IBOutlet weak var videoLength: UILabel!

  
  
    override func awakeFromNib() {
        super.awakeFromNib()
      
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
