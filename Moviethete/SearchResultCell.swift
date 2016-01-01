//
//  SearchResultCell.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 8/16/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var localizedMovieTitle: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
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
    super.prepareForReuse()
    posterImage.image = nil
    posterImage.sd_cancelCurrentImageLoad()
  }
    
}
