//
//  LoadingIndicatorView.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 12/21/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
import Async

let LoadingIndicatorViewTag = 777
//let kTickTimeInterval = 0.5 // 0.5.second

class LoadingIndicatorView: UIView {
  
  var loadingIndicatorView: UIActivityIndicatorView!
  
  init() {
    super.init(frame: CGRect.zero)
    setup()
  }

  required init(coder aDecoder:NSCoder) {
    super.init(coder:aDecoder)!
    setup()
  }

  func setup() {
    Async.main {
      let currentVCView = UIViewController.currentViewController().view
      self.frame = CGRectMake(0, 0, 70, 70)
      self.center = currentVCView.center
      self.layer.cornerRadius = 8
      self.layer.masksToBounds = true
      self.tag = LoadingIndicatorViewTag
      self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
      self.loadingIndicatorView = UIActivityIndicatorView(frame: self.bounds)
      self.addSubview(self.loadingIndicatorView)
      self.loadingIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
      self.loadingIndicatorView.startAnimating()
      self.addSubview(self.loadingIndicatorView)
    }
  }
  
  func toggleTickWithTimeIntervalExpirationBlock(timeIntervalExpirationBlock: (() -> Void)) {
    Async.main {
      if self.loadingIndicatorView.isAnimating() {
        self.loadingIndicatorView.stopAnimating()
        let tickImageView = UIImageView(image: UIImage(named: "Tick"))
        tickImageView.frame.size = CGSizeMake(40, 35)
        tickImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        self.addSubview(tickImageView)
//        NSTimer.after(kTickTimeInterval, { () -> Void in
//          self.removeFromSuperview()
//          timeIntervalExpirationBlock()
//        })
      }
    }
  }

}





