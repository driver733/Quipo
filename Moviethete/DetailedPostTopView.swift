//
//  DetailedPostCell.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 8/29/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
import HCSStarRatingView


  

  
@IBDesignable class DetailedPostTopView: UIView{
  
  var view:UIView!
  
  @IBOutlet weak var lblTitle: UILabel!
  
  @IBInspectable var lblTitleText : String?
    {
    get{
      return lblTitle.text;
    }
    set(lblTitleText)
    {
      lblTitle.text = lblTitleText!
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
 
  
  
}

