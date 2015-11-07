//
//  PlotCell.swift
//  Moviethete
//
//  Created by Mike on 11/5/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import UIKit

class PlotCell: UITableViewCell {


  @IBOutlet weak var plot: UILabel!
  @IBOutlet weak var more: UIButton!
  
    override func awakeFromNib() {
      super.awakeFromNib()
      self.contentView.userInteractionEnabled = false
      // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  

//  override func prepareForReuse() {
//    moreButton.frame = CGRectZero
//  }
}
