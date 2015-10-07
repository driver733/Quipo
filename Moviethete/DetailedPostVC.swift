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

class DetailedPostVC: UIViewController {


  @IBOutlet var tableView: UITableView!
  
  var loginActivityIndicator: UIActivityIndicatorView!
  let loginActivityIndicatorBackgroundView = UIView()
  
  var passedPosterImage: UIImage? = nil
  var passedMovieInfo = Dictionary<String, String>()
  var passedPost: Post? = nil
  var passedColor = UIColor()
  var textColor = UIColor()
  var navBarShadowImage = UIImage()
  var navBarBackgroundImage = UIImage()
  
  var reviews = [UserReview]()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNib(UINib(nibName: "DetailedPostMainCell", bundle: nil), forCellReuseIdentifier: "detailedPostCell")
    tableView.registerNib(UINib(nibName: "UserReviewCell", bundle: nil), forCellReuseIdentifier: "userReviewCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    
    self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "addPost"), animated: true)
    
  
    self.navigationController?.navigationBar.shadowImage = (getImageWithColor(UIColor.lightGrayColor(), size: (CGSizeMake(0.35, 0.35))))
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
    self.navigationController?.navigationBar.tintColor = textColor
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : textColor]
    self.transitionCoordinator()?.animateAlongsideTransition({
      (context: UIViewControllerTransitionCoordinatorContext) -> Void in
      self.navigationController?.navigationBar.subviews[1].hidden = true
      self.navigationController?.navigationBar.barTintColor = self.passedColor
      },
      completion: nil)
    
    startLoginActivityIndicator()
    
    
    
    
    
    Post.sharedInstance.loadMovieReviewsForMovie((passedPost?.trackID)!, withoutPostFromFeedWithObjectId: passedPost?.pfObject.objectId) { (reviews) -> Void in
      if !(reviews!.isEmpty) {
        self.reviews = reviews!
        self.putFeedReviewToTheBeginning()
        self.tableView.reloadData()
      }
      self.stopLoginActivityIndicator()
    }
    
    
  }
  
  
  func putFeedReviewToTheBeginning() {
    if let passedPostObjectId = self.passedPost?.pfObject.objectId {
      for (index, review) in reviews.enumerate() {
        if review.pfObject?.objectId == passedPostObjectId {
          let feedReview = reviews.removeAtIndex(index)
          reviews.insert(feedReview, atIndex: 0)
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
      if !reviews.isEmpty {
        let cell = tableView.dequeueReusableCellWithIdentifier("userReviewCell", forIndexPath: indexPath) as! UserReviewCell
        let review = reviews[indexPath.row - 1]
        cell.profileImage.sd_setImageWithURL(NSURL(string: (review.pfUser!["smallProfileImage"] as! String)))
        cell.userName.text = review.pfUser?.username
        cell.timeSincePosted.text = review.timeSincePosted
        cell.reviewTitle.text = review.title
        cell.review.text = review.review
        cell.rating.value = CGFloat(review.starRating!)
        return cell
      }
      return UITableViewCell()
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reviews.count + 1
  }
  
}

















