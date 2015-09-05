//
//  CustomCell.swift
//  Reviews
//
//  Created by Admin on 02/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

class ContentCell: UITableViewCell {
    
    @IBOutlet weak var posterImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
  override func prepareForReuse() {
    posterImage.image = nil // put placeholder image - light gray color
  }

    
}
