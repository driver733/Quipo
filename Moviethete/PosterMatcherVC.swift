//
//  PosterMatcherVC.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 12/31/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
import ALCameraViewController
import Bolts
import SDWebImage
import Async

class PosterMatcherVC: UIViewController {
  
  var delegate: LoadingStateDelegate?
  
   var passedViewScreenshot: UIImage!
  
  override func loadView() {
    self.view = UIView.loadFromNibNamed("PosterMatcherDemo")!
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let takePhotoButton = self.subViewWithRestorationID("takePhoto") as! UIButton
    takePhotoButton.addTarget(self, action: "didTapTakePhotoButton:", forControlEvents: .TouchUpInside)
    
  }

  func didTapTakePhotoButton(sender: UIButton!) {
//    let cameraViewController = ALCameraViewController(croppingEnabled: false) { image in
//      if let image = image {
//
//        for view in (self.view.subviews) {
//          view.removeFromSuperview()
//        }
//        let imageView = UIImageView(frame: self.view.frame)
//        imageView.image = self.passedViewScreenshot
//        self.view.addSubview(imageView)
//        self.dismissViewControllerAnimated(true, completion: { () -> Void in
//          self.presentingViewController?.dismissViewControllerAnimated(false, completion: { () -> Void in
//            self.delegate?.didStartNetworingActivity()
//            PosterMovieNameMatcher.movieNameOfPoster(image).continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
//              let movieName = task.result as! String
//              ITunes.sharedInstance.movieInfoByTitleAtCountry(movieName, country: "US", completionHandler: { (searchResults) -> Void in
//                let post = searchResults[0]
//                SDWebImageDownloader.sharedDownloader().downloadImageWithURL(NSURL(string: post.smallPosterImageURL!), options: SDWebImageDownloaderOptions.HighPriority, progress: nil, completed: { (image: UIImage!, _, error: NSError!, _) -> Void in
//                  if error == nil {
//                    self.delegate?.didEndNetworingActivity()
//                    let colors = self.primaryPosterImageColorAndtextColor(image)
//                    let vc = DetailedPostVC(thePost: post , theNavBarBackgroundColor: colors.primaryColor, theNavBarTextColor: colors.inferredTextColor)
//                      ((UIViewController.currentViewController() as! UITabBarController).selectedViewController as! UINavigationController).pushViewController(vc, animated: true)
//                  }
//                })
//              })
//              return nil
//            })
//          })
//
//        })
//
//
//
//      }
//
//      for view in (self.view.subviews) {
//        view.removeFromSuperview()
//      }
//      let imageView = UIImageView(frame: self.view.frame)
//      imageView.image = self.passedViewScreenshot
//      self.view.addSubview(imageView)
//      self.dismissViewControllerAnimated(true, completion: { () -> Void in
//        self.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
//      })
//
//    }
//    presentViewController(cameraViewController, animated: true, completion:  nil)
  }
  
  
 
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}










