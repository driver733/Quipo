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

class DetailedPostVC: UIViewController {


  var tableView = UITableView()
  
  var loginActivityIndicator: UIActivityIndicatorView!
  let loginActivityIndicatorBackgroundView = UIView()
  
  var passedPosterImage: UIImage? = nil
  var passedMovieInfo = Dictionary<String, String>()
  var passedPost: Post? = nil
  var passedColor = UIColor()
  var textColor = UIColor()
  var navBarShadowImage = UIImage()
  var navBarBackgroundImage = UIImage()

    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    tableView.dataSource = self
    tableView.registerNib(UINib(nibName: "DetailedPostMainCell", bundle: nil), forCellReuseIdentifier: "detailedPostCell")
    tableView.registerNib(UINib(nibName: "TopCell", bundle: nil), forCellReuseIdentifier: "TopCell")
    tableView.registerNib(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "reviewCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    
    self.view = tableView
    
    self.navigationController?.navigationBar.shadowImage = (getImageWithColor(UIColor.lightGrayColor(), size: (CGSizeMake(0.35, 0.35))))
    
    
    
    self.title = passedPost!.movieTitle!
    
  
    
    
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
    performSegueWithIdentifier("addPost", sender: nil)
  }
  
  
  override func viewWillAppear(animated: Bool) {
    
    self.transitionCoordinator()?.animateAlongsideTransition({
      (context: UIViewControllerTransitionCoordinatorContext) -> Void in
      if self.navigationController!.viewControllers[0].isKindOfClass(SearchVC) {
        self.navigationController?.navigationBar.subviews[1].hidden = true             // hide search bar if it is present
      }
      self.navigationController?.navigationBar.barTintColor = self.passedColor
      self.navigationController?.navigationBar.tintColor = self.textColor
      self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : self.textColor]
      },
      completion: { (completionContext: UIViewControllerTransitionCoordinatorContext) -> Void in
        self.navigationController?.navigationBar.barTintColor = self.passedColor
        self.navigationController?.navigationBar.tintColor = self.textColor
    })
    
    
    
    //   startLoginActivityIndicator()
    
  
    
    // do only after posting a review!
    
    Post.sharedInstance.loadMovieReviewsForMovie((passedPost?.trackID)!).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      if !UserReview.sharedInstance.selectedMovieReviews.isEmpty {
        self.putFeedReviewToTheBeginning()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "addPost"), animated: false)
        self.tableView.reloadData()
      } else {
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "addPost"), animated: false)
      }
      //     self.stopLoginActivityIndicator()
      return nil
    }

    
   
    
    
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
      for (index, review) in UserReview.sharedInstance.selectedMovieReviews.enumerate() {
        
        if (review.pfObject?.objectId)! == passedPostObjectId {
          feedReviewIndex = index
        } else if (review.pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
          currentUserReviewIndex = index
        }
        
      }
      
      if let feedReviewIndex = feedReviewIndex {
        
        if let currentUserReviewIndex = currentUserReviewIndex {
          UserReview.sharedInstance.selectedMovieReviews.insert(UserReview.sharedInstance.selectedMovieReviews.removeAtIndex(currentUserReviewIndex), atIndex: 0)
        }
        UserReview.sharedInstance.selectedMovieReviews.insert(UserReview.sharedInstance.selectedMovieReviews.removeAtIndex(feedReviewIndex), atIndex: 0)
        
      } else {
        if let currentUserReviewIndex = currentUserReviewIndex {
          UserReview.sharedInstance.selectedMovieReviews.insert(UserReview.sharedInstance.selectedMovieReviews.removeAtIndex(currentUserReviewIndex), atIndex: 0)
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
      
      for review in UserReview.sharedInstance.selectedMovieReviews {
        if (review.pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
          vc.passedReview = review
        }
      }
      
      
    }
  }
  
  
}


extension DetailedPostVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch indexPath.row {
      
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("detailedPostCell", forIndexPath: indexPath) as! DetailedPostCell
      cell.posterImage.sd_setImageWithURL(NSURL(string: (passedPost?.standardPosterImageURL)!),
        placeholderImage: getImageWithColor(UIColor.lightGrayColor(),size: cell.posterImage.bounds.size))
      cell.movieInfo.text = passedPost?.movieGenre
      cell.movieInfo.textColor = textColor
      return cell
      
    default:
      if !UserReview.sharedInstance.selectedMovieReviews.isEmpty {
        let review = UserReview.sharedInstance.selectedMovieReviews[getCellPostIndex(indexPath.row - 1)]
        if indexPath.row % 2 != 0 {
          let cell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopCell
          cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
          cell.profileImage.sd_setImageWithURL(NSURL(string: (review.pfUser!["smallProfileImage"] as! String)),
            placeholderImage: getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.bounds.size),
            options: SDWebImageOptions.RefreshCached, completed: { (image: UIImage!, erro: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
              cell.profileImage.image = Toucan(image: image).maskWithEllipse().image
          })
          cell.userName.text = review.pfUser?.username
          cell.timeSincePosted.text = review.timeSincePosted
          return cell
      }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewCell
        cell.reviewTitle.text = "- " + review.title!
        cell.reviewText.text = review.review!
        cell.rating.value = CGFloat(review.starRating!)
        return cell
        
      }
      
      return UITableViewCell()
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return UserReview.sharedInstance.selectedMovieReviews.count * 2 + 1
  }
  
}

















