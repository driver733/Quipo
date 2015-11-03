//
//  DetailedPostVC.swift
//  Reviews
//
//  Created by Admin on 06/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import SDWebImage
import Async
import Bolts
import Parse
import DynamicBlurView
import HCSStarRatingView


class DetailedPostVC: UIViewController {
  
  var lastContentOffset = CGFloat()
  var tableView = UITableView()
  var movieInfoTableView = UITableView()
  
  var loginActivityIndicator: UIActivityIndicatorView!
  let loginActivityIndicatorBackgroundView = UIView()
  
  var passedPost: Post? = nil
  var passedColor: UIColor? = nil
  var textColor: UIColor? = nil
  
  lazy var currentUserReview: UserReview? = {
    if !UserReview.sharedInstance.movieReviewsForSelectedMovie.isEmpty {
      if (UserReview.sharedInstance.movieReviewsForSelectedMovie[0].pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
        return UserReview.sharedInstance.movieReviewsForSelectedMovie[0]
      } else {
        if UserReview.sharedInstance.movieReviewsForSelectedMovie.count > 1 {
          if (UserReview.sharedInstance.movieReviewsForSelectedMovie[0].pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
            return UserReview.sharedInstance.movieReviewsForSelectedMovie[1]
          }
        }
      }
    }
    return nil
  }()
  
  func didTapFavButton(sender: UIButton) {
    
  }
  
  func didTapWatchedButton(sender: UIButton) {
    
  }
  
  
  func didChangeSection(sender: UISegmentedControl ) {
    switch sender.selectedSegmentIndex {
      
    case 0:
      self.view = tableView
    case 1:
    //  self.view = movieInfoTableView
      
    default: break
    }
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.registerNib(UINib(nibName: "DetailedPostMainCell", bundle: nil), forCellReuseIdentifier: "detailedPostCell")
    tableView.registerNib(UINib(nibName: "TopCell", bundle: nil), forCellReuseIdentifier: "TopCell")
    tableView.registerNib(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "reviewCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    
    

    self.view = tableView
    
  
    let headerView = UIView(frame: CGRectMake(0, 64, 0, 180))
    
    let headerContentView = UIView.loadFromNibNamed("DetailedPostTopView")!
    headerContentView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.85)
    headerContentView.frame = headerView.frame
    headerContentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    
    for subView in headerContentView.subviews {
      if subView.isKindOfClass(UISegmentedControl) {
        let segControl = subView as! UISegmentedControl
        segControl.addTarget(self, action: Selector("didChangeSection:"), forControlEvents: .AllEvents)
      }
      if subView.isKindOfClass(UIButton) {
        let button = subView as! UIButton
        if button.restorationIdentifier == "fav" {
          button.addTarget(self, action: Selector("didTapFavButton:"), forControlEvents: .TouchUpInside)
        } else if button.restorationIdentifier == "watched" {
          button.addTarget(self, action: Selector("didTapWatchedButton:"), forControlEvents: .TouchUpInside)
        }
        
      }
    }
   
    headerView.addSubview(headerContentView)

 
    tableView.tableHeaderView = headerView

    
    


    movieInfoTableView.dataSource = self
    movieInfoTableView.delegate = self
    
    self.navigationController?.navigationBar.shadowImage = (getImageWithColor(UIColor.placeholderColor(), size: (CGSizeMake(0.35, 0.35))))
    
    self.title = passedPost!.movieTitle!
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
    movieInfoTableView.tableFooterView = UIView(frame: CGRectZero)
  }
  


  
  func startLoginActivityIndicator() {
    loginActivityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 10, 10)) as UIActivityIndicatorView
    loginActivityIndicatorBackgroundView.frame = self.view.frame
    loginActivityIndicatorBackgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    loginActivityIndicatorBackgroundView.center = self.view.center
    loginActivityIndicator.center = self.view.center
    loginActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    loginActivityIndicatorBackgroundView.addSubview(loginActivityIndicator)
    self.view.addSubview(loginActivityIndicatorBackgroundView)
    loginActivityIndicator.startAnimating()
  }
  
  func stopLoginActivityIndicator() {
    if loginActivityIndicator != nil {
      loginActivityIndicator.stopAnimating()
      loginActivityIndicator.removeFromSuperview()
      loginActivityIndicatorBackgroundView.removeFromSuperview()
    }
  }
  
  
  func addPost() {
    let vc = AddMovieReviewVC()
    vc.post = passedPost!
    if let review = currentUserReview {
      vc.passedReview = review
    }
    for review in UserReview.sharedInstance.movieReviewsForSelectedMovie {
      if (review.pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
        vc.passedReview = review
      }
    }
    let navController = UINavigationController(rootViewController: vc)
    self.presentViewController(navController, animated: true, completion: nil)
  }
  
  
  override func viewWillAppear(animated: Bool) {
    
  
    if passedColor != nil && textColor != nil {
    
    
    self.transitionCoordinator()?.animateAlongsideTransition({
      (context: UIViewControllerTransitionCoordinatorContext) -> Void in
      if self.navigationController!.viewControllers[0].isKindOfClass(SearchVC) {
        self.navigationController?.navigationBar.subviews[1].hidden = true             // hide search bar if it is present
      }
      self.navigationController?.navigationBar.barTintColor = self.passedColor
      self.navigationController?.navigationBar.tintColor = self.textColor
      self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : self.textColor!]
      },
      completion: { (completionContext: UIViewControllerTransitionCoordinatorContext) -> Void in
        self.navigationController?.navigationBar.barTintColor = self.passedColor
        self.navigationController?.navigationBar.tintColor = self.textColor
    })
    
      }
    
    //   startLoginActivityIndicator()
    
  
    
    // do only after posting a review!
    
    Post.sharedInstance.loadMovieReviewsForMovie((passedPost?.trackID)!).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      if self.userHasReviewForSelectedMovie() {
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "addPost"), animated: false)
      } else {
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "addPost"), animated: false)
      }
      self.putFeedReviewToTheBeginning()
      self.tableView.reloadData()
      //     self.stopLoginActivityIndicator()
      return nil
    }

    
   
    
    
  }
  
  // Move to Singleton
  func userHasReviewForSelectedMovie() -> Bool {
    for review in UserReview.sharedInstance.movieReviewsForSelectedMovie {
      if (review.pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
        return true
      }
    }
    return false
  }
  
  
  
  
  func getCellPostIndex(index: Int) -> Int {
    if index % 2 == 0 {
      return index / 2
    } else {
      return Int(floor(Double(index / 2)))
    }
  }
  
  func putFeedReviewToTheBeginning() {
    if let passedPostObjectId = self.passedPost?.pfObject.objectId {
    
      var feedReviewIndex: Int? = Int()
      var currentUserReviewIndex: Int? = Int()
      for (index, review) in UserReview.sharedInstance.movieReviewsForSelectedMovie.enumerate() {
        
        if (review.pfObject?.objectId)! == passedPostObjectId {
          feedReviewIndex = index
        } else if (review.pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
          currentUserReviewIndex = index
        }
        
      }
      
      if let feedReviewIndex = feedReviewIndex {
        
        if let currentUserReviewIndex = currentUserReviewIndex {
          UserReview.sharedInstance.movieReviewsForSelectedMovie.insert(UserReview.sharedInstance.movieReviewsForSelectedMovie.removeAtIndex(currentUserReviewIndex), atIndex: 0)
        }
        UserReview.sharedInstance.movieReviewsForSelectedMovie.insert(UserReview.sharedInstance.movieReviewsForSelectedMovie.removeAtIndex(feedReviewIndex), atIndex: 0)
        
      } else {
        if let currentUserReviewIndex = currentUserReviewIndex {
          UserReview.sharedInstance.movieReviewsForSelectedMovie.insert(UserReview.sharedInstance.movieReviewsForSelectedMovie.removeAtIndex(currentUserReviewIndex), atIndex: 0)
        }
      }
      

    }
  }
  
  
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = (segue.destinationViewController as? UINavigationController)?.viewControllers[0] as? AddMovieReviewVC {
      vc.post = passedPost!
      
      for review in UserReview.sharedInstance.movieReviewsForSelectedMovie {
        if (review.pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
          vc.passedReview = review
        }
      }
      
      
    }
  }
  
  
}


extension DetailedPostVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  
      
//    case 0:
//      let cell = tableView.dequeueReusableCellWithIdentifier("detailedPostCell", forIndexPath: indexPath) as! DetailedPostCell
//      cell.posterImage.sd_setImageWithURL(NSURL(string: (passedPost?.standardPosterImageURL)!),
//        placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.posterImage.bounds.size))
//      cell.movieRating.userInteractionEnabled = false
//      cell.selectionStyle = .None
//      cell.segmentedControl.addTarget(self, action: Selector("didChangeSection:"), forControlEvents: .AllEvents)
//      return cell
      
  
      if !UserReview.sharedInstance.movieReviewsForSelectedMovie.isEmpty {
        let review = UserReview.sharedInstance.movieReviewsForSelectedMovie[getCellPostIndex(indexPath.row - 1)]
        if indexPath.row % 2 == 0 {
          let cell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopCell
          
          cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
          cell.profileImage.sd_setImageWithURL(NSURL(string: (review.pfUser!["smallProfileImage"] as! String)),
            placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
            options: SDWebImageOptions.RefreshCached, completed: { (image: UIImage!, erro: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
              cell.profileImage.image = Toucan(image: image).maskWithEllipse().image
              
          })
          cell.userName.text = review.pfUser?.username
          cell.timeSincePosted.text = review.timeSincePosted
          cell.selectionStyle = .None
          return cell
      }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewCell
        cell.reviewTitle.text = "- " + review.title!
        cell.reviewText.text = review.review!
        cell.rating.value = CGFloat(review.starRating!)
        cell.selectionStyle = .None
        return cell
        
      }
      
      return UITableViewCell()
    }
  
  
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return UserReview.sharedInstance.movieReviewsForSelectedMovie.count * 2
  }
  
  
  
  
}





extension DetailedPostVC: UITableViewDelegate {
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    scrollView.bounces = true
  }
 
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    let headerContentView = tableView.tableHeaderView?.subviews[0]
    headerContentView?.transform = CGAffineTransformMakeTranslation(0, offsetY)
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
      cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
    }
  }
}








