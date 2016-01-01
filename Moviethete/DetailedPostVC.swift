//
//  DetailedPostVC.swift
//  Reviews
//
//  Created by Mikhail Yakushin on 06/07/15.
//  Copyright (c) 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
import SDWebImage
import Async
import Bolts
import Parse
import HCSStarRatingView
import Alamofire
import XCDYouTubeKit

class DetailedPostVC: UIViewController {
  
  let kTableHeaderViewHeight: CGFloat = 64
  
  var numberOfReviews: UILabel!
  var starred: UIButton!
  var watched: UIButton!
 // var avgMovieRating: HCSStarRatingView!
  
  var reviews = [UserReview]!()
  var userMediaInfo: UserMedia!
  
  var tableView: UITableView!
  var selectedTableViewSection = 0
  var firstSectionContentOffset: CGPoint!
  var secondSectionContentOffset: CGPoint!
  
  var loginActivityIndicator: UIActivityIndicatorView!
  let loginActivityIndicatorBackgroundView = UIView()
  
  var cellLoadingIndicator: UIActivityIndicatorView!
  
  var post: Post?
  var navBarBackgroundColor: UIColor?
  var navBarTextColor: UIColor?
  
  
  
  init(thePost: Post, theNavBarBackgroundColor: UIColor, theNavBarTextColor: UIColor) {
    super.init(nibName: nil, bundle: nil)
    post = thePost
    navBarBackgroundColor = theNavBarBackgroundColor
    navBarTextColor = theNavBarTextColor
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
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
  
  func currentUserReview() -> UserReview? {
    if !reviews.isEmpty {
      if (reviews[0].pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
        return reviews[0]
      } else {
        if reviews.count > 1 {
          if (reviews[0].pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
            return reviews[1]
          }
        }
      }
    }
    return nil
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView = UITableView()
    self.view = tableView
    tableView.dataSource = self
    tableView.delegate = self
    tableView.registerNib(UINib(nibName: "DetailedPostMainCell", bundle: nil), forCellReuseIdentifier: "detailedPostCell")
    tableView.registerNib(UINib(nibName: "TopCell", bundle: nil), forCellReuseIdentifier: "TopCell")
    tableView.registerNib(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "reviewCell")
    tableView.registerNib(UINib(nibName: "TrailersCell", bundle: nil), forCellReuseIdentifier: "trailersCell")
    tableView.registerNib(UINib(nibName: "PlotCell", bundle: nil), forCellReuseIdentifier: "plotCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
  
    setupTableHeaderView()
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    self.navigationController?.navigationBar.shadowImage = (getImageWithColor(UIColor.placeholderColor(), size: (CGSizeMake(0.35, 0.35))))
    self.title = post!.movieTitle!
    
    let gesture = UITapGestureRecognizer(target: self, action: "didTapSuperview:")
    self.view.addGestureRecognizer(gesture)
    gesture.cancelsTouchesInView = false
    
    self.navigationController?.navigationBar.translucent = false  //   have yet to figure out how the contentInset
    scrollViewDidScroll(tableView)                                //   of the tableView header works; using this workaround for now.
    
    BFTask(forCompletionOfAllTasksWithResults: [
      UserMedia.userMediaInfoForMovieWithTrackID(post!.trackID!),
      Post.sharedInstance.loadMovieReviewsForMovie((post!.trackID)!)
      ]).continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
        let results = task.result as! NSArray
        self.userMediaInfo = results[0] as! UserMedia
        self.reviews = results[1] as! [UserReview]
        if self.currentUserHasReviewForSelectedMovie() {
          self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "addPost"), animated: false)
        } else {
          self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "addPost"), animated: false)
        }
        self.numberOfReviews.text = "(\(self.reviews.count))"
        // self.avgMovieRating.value = CGFloat(UserReview.sharedInstance.avgMovieRatingForSelectedMovie)
        
        if self.userMediaInfo.isWatched {
          self.watched.setTitle("Watched", forState: .Normal)
          self.watched.setTitleColor(UIColor.greenColor(), forState: .Normal)
        } else {
          self.watched.setTitle("Watched+", forState: .Normal)
          self.watched.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }
        if self.userMediaInfo.isStarred {
          self.starred.setTitle("Favorite", forState: .Normal)
          self.starred.setTitleColor(UIColor.greenColor(), forState: .Normal)
        } else {
          self.starred.setTitle("Favorite+", forState: .Normal)
          self.starred.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }
     
        self.putFeedReviewToTheBeginning()
        self.tableView.reloadData()
          
        return nil
    })
   
    
    
  }

  func currentUserHasReviewForSelectedMovie() -> Bool {
    for review in reviews {
      if (review.pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
        return true
      }
    }
    return false
  }
  
  
  
  override func viewWillAppear(animated: Bool) {
      self.transitionCoordinator()?.animateAlongsideTransition({
        (context: UIViewControllerTransitionCoordinatorContext) -> Void in
//        if self.navigationController!.viewControllers[0].isKindOfClass(SearchVC) {
//          self.navigationController?.navigationBar.subviews[1].hidden = true           // hide search bar if it is present
//        }
        self.navigationController?.navigationBar.barTintColor = self.navBarBackgroundColor
        self.navigationController?.navigationBar.tintColor = self.navBarTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : self.navBarTextColor!]
        },
        completion: { (completionContext: UIViewControllerTransitionCoordinatorContext) -> Void in
          self.navigationController?.navigationBar.barTintColor = self.navBarBackgroundColor
          self.navigationController?.navigationBar.tintColor = self.navBarTextColor
      })
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = (segue.destinationViewController as? UINavigationController)?.viewControllers[0] as? AddMovieReviewVC {
      vc.post = post!
      for review in reviews {
        if (review.pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
          vc.passedReview = review
        }
      }
    }
  }
  
  
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - Buttons
  
  
  
  func didTapCommentsButton(sender: UIButton) {

    var parentView = sender.superview!
    while (!(parentView.isKindOfClass(ReviewCell)) ) {
      parentView = parentView.superview!
    }
    
    
    let cell = parentView as! ReviewCell
    
    let vc = CommentsVC(tableViewStyle: .Plain)
    vc.passedReview = reviews[getCellPostIndex((tableView.indexPathForCell(cell)?.row)!)]
    
    
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  
  func didTapMoreTextButton(sender: UIButton) {
    let plotCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! PlotCell
    plotCell.plot.removeConstraints(plotCell.plot.constraints)
    plotCell.more.setTitle("...less", forState: .Normal)
    let offset = tableView.contentOffset
    tableView.reloadData()
    tableView.layoutIfNeeded()
    tableView.setContentOffset(offset, animated: false)
  }
 
  
  
  
  func didTapFavButton(sender: UIButton) {
    if userMediaInfo.isStarred {
      userMediaInfo.markMovie((post?.trackID)!, AsStarred: false, pfObject: userMediaInfo.pfObject).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        sender.setTitle("+ Starred", forState: .Normal)
        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
        return nil
      }
    } else {
      userMediaInfo.markMovie((post?.trackID)!, AsStarred: true, pfObject: userMediaInfo.pfObject).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        sender.setTitle("Starred", forState: .Normal)
        sender.setTitleColor(UIColor.greenColor(), forState: .Normal)
        return nil
      }
    }
  }
  
  func didTapWatchedButton(sender: UIButton) {
    if userMediaInfo.isWatched {
      userMediaInfo.markMovie((post?.trackID)!, AsWatched: false, pfObject: userMediaInfo.pfObject).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        sender.setTitle("+ Watched", forState: .Normal)
        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
        return nil
      }
    } else {
      userMediaInfo.markMovie((post?.trackID)!, AsWatched: true, pfObject: userMediaInfo.pfObject).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        sender.setTitle("Watched", forState: .Normal)
        sender.setTitleColor(UIColor.greenColor(), forState: .Normal)
        return nil
      }
    }
  }
  
  
  func didChangeSection(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
      
    case 0:
      selectedTableViewSection = 0
      secondSectionContentOffset = tableView.contentOffset
      tableView.reloadData()
      tableView.layoutIfNeeded()
      setContentOffset()
    case 1:
      selectedTableViewSection = 1
      firstSectionContentOffset = tableView.contentOffset
      tableView.contentSize.height += 20

      if let _ = YouTube.sharedInstance.currentThumbnailURL {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        setContentOffset()
      } else {
        
        YouTube.sharedInstance.getMovieTrailerWithMovieTitle((post?.movieTitle)!, releasedIn: (post?.releaseYear)!).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
          
          let videoInfo = task.result as! [String]
          let trailerId = videoInfo[0]
          let thumbnailURL = videoInfo[1]
          let videoDuration = videoInfo[2]
          
          YouTube.sharedInstance.currentTrailerId = trailerId
          YouTube.sharedInstance.currentThumbnailURL = thumbnailURL
          YouTube.sharedInstance.currenVideoDuration = videoDuration
          
          self.tableView.reloadData()
          
          return nil
        })

      }
     
      
    default: break
    }
  }

  func setContentOffset() {
    switch selectedTableViewSection {
    case 0:
      if firstSectionContentOffset != nil {
        tableView.setContentOffset(firstSectionContentOffset, animated: false)
      }
    case 1:
      if secondSectionContentOffset != nil {
        tableView.setContentOffset(secondSectionContentOffset, animated: false)
      }
    default:
      break
    }
  }

  func didTapSuperview(press: UITapGestureRecognizer) {
    
    if press.state == .Ended {
      
      let location = press.locationInView(self.view)
      let tableViewHeaderContentView = (tableView.tableHeaderView?.subviews[2])!
      let point = tableViewHeaderContentView.convertPoint(location, fromView: tableView)
      if tableViewHeaderContentView.pointInside(point, withEvent: nil) {
        for subView in tableViewHeaderContentView.subviews {
          
          let newPoint = subView.convertPoint(location, fromView: tableView)
          
          if subView.pointInside(newPoint, withEvent: nil) {
            
            switch subView.restorationIdentifier! {
              
            case "moviePoster":
              let moviePoster = subView as! UIImageView
              // open high res poster image on touch
              
            case "segmCtrl":
              let segControl = subView as! UISegmentedControl
              let sectionChosen = newPoint.x / segControl.bounds.width
              if sectionChosen < 0.5 {
                segControl.selectedSegmentIndex = 0
              } else {
                segControl.selectedSegmentIndex = 1
              }
              didChangeSection(segControl)
            
            case "+fav":
              let button = subView as! UIButton
              didTapFavButton(button)
              
            case "+watched":
              let button = subView as! UIButton
              didTapWatchedButton(button)
              
            default:
              break
              
            }

            
            
            
          }
          
        }

      }
        
        
      
 
      let path = tableView.indexPathForRowAtPoint(location)
      if path?.row == 0  {
        if selectedTableViewSection == 1 {
          let cell = tableView.cellForRowAtIndexPath(path!) as! TrailersCell
          
          var viewPoint = cell.thumbnail.convertPoint(location, fromView: tableView)
          if cell.thumbnail.pointInside(viewPoint, withEvent: nil) {
            
            
            let vc = XCDYouTubeVideoPlayerViewController(videoIdentifier: YouTube.sharedInstance.currentTrailerId!)
            self.presentViewController(vc, animated: true, completion: nil)
            
          }

          

        }

      
      }
      
   
      
    }
  }
  
  
  
  // MARK: - Utility
  
  
  
  func setupTableHeaderView() {
    let headerContentView = UIView.loadFromNibNamed("DetailedPostTopView")!
    
    headerContentView.backgroundColor = UIColor.clearColor()
    headerContentView.frame = CGRectMake(0, kTableHeaderViewHeight, self.view.frame.width, 180)
    headerContentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    
    for subView in headerContentView.subviews {
      
      switch subView.restorationIdentifier! {
        
      case "moviePoster":
        let moviePoster = subView as! UIImageView
        moviePoster.sd_setImageWithURL(NSURL(string: (post?.standardPosterImageURL)!), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: moviePoster.frame.size))

      case "movieTitle":
        let movieName = subView as! UILabel
        movieName.text = post?.movieTitle
        
      case "+fav":
        let button = subView as! UIButton
        button.setTitle("", forState: .Normal)
        starred = button
        
      case "+watched":
        let button = subView as! UIButton
        button.setTitle("", forState: .Normal)
        watched = button
        
      case "numberOfReviews":
        let label = subView as! UILabel
        numberOfReviews = label
        label.text = ""
        label.font = label.font.fontWithSize(12)
        
      case "movieRating":
        let movieRating = subView as! HCSStarRatingView
        movieRating.backgroundColor = UIColor.clearColor()
        movieRating.value = 3
   //     movieRating.value = CGFloat((post?.rating)!) // change to average rating amongst friends
        movieRating.userInteractionEnabled = false
        
      default:
        break
        
      }
      
    }
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    visualEffectView.frame = headerContentView.frame
    visualEffectView.addSubview(headerContentView)
    

    tableView.tableHeaderView = visualEffectView
  }
  
  
  func addPost() {
    let vc = AddMovieReviewVC()
    vc.post = post!
    if let review = currentUserReview() {
      vc.passedReview = review
    }
    for review in reviews {
      if (review.pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
        vc.passedReview = review
      }
    }
    let navController = UINavigationController(rootViewController: vc)
    self.presentViewController(navController, animated: true, completion: nil)
  }
  
  
  
  
  
  

  
  
  
  func getCellPostIndex(index: Int) -> Int {
    if index % 2 == 0 {
      return index / 2
    } else {
      return Int(floor(Double(index / 2)))
    }
  }
  
  func putFeedReviewToTheBeginning() {
    if let passedPostObjectId = self.post?.pfObject.objectId {
    
      var feedReviewIndex: Int?
      var currentUserReviewIndex: Int?
      for (index, review) in reviews.enumerate() {
        
        if (review.pfObject?.objectId)! == passedPostObjectId {
          feedReviewIndex = index
        } else if (review.pfUser?.objectId)! == (PFUser.currentUser()?.objectId)! {
          currentUserReviewIndex = index
        }
        
      }
      
      if let feedReviewIndex = feedReviewIndex {
        
        if let currentUserReviewIndex = currentUserReviewIndex {
          reviews.insert(reviews.removeAtIndex(currentUserReviewIndex), atIndex: 0)
        } // crash
        reviews.insert(reviews.removeAtIndex(feedReviewIndex), atIndex: 0)
        
      } else {
        if let currentUserReviewIndex = currentUserReviewIndex {
          reviews.insert(reviews.removeAtIndex(currentUserReviewIndex), atIndex: 0)
        }
      }
      

    }
  }
  
  
  
}


// MARK: - UITableViewDataSource
extension DetailedPostVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  
    if selectedTableViewSection == 1 {
      
      switch indexPath.row {
        
      case 0:
        
        if let _ = YouTube.sharedInstance.currentThumbnailURL {
          
        let cell = tableView.dequeueReusableCellWithIdentifier("trailersCell") as! TrailersCell
        cell.selectionStyle = .None
        cell.videoLength.font = cell.videoLength.font.fontWithSize(13)
        cell.videoLength.text = YouTube.sharedInstance.currenVideoDuration
        cell.videoType.font = cell.videoType.font.fontWithSize(13)
        if let currentThumbnailURL = YouTube.sharedInstance.currentThumbnailURL {
          cell.thumbnail.sd_setImageWithURL(NSURL(string: currentThumbnailURL), placeholderImage: self.getImageWithColor(UIColor.placeholderColor(), size: cell.bounds.size), completed: { (image: UIImage!, error: NSError!, _, _) -> Void in
            if image != nil && error == nil {
              let img = self.getImageWithColor(UIColor.redColor(), size: CGSizeMake(30, 30))
              let view = UIImageView(frame: CGRectMake(0, 0, 30, 30))
              view.image = img
            }
          })

        }
        
        return cell
          
        } else {
          
          let cell = UITableViewCell(frame: CGRectMake(0, 0, self.view.bounds.width, 10))
          cellLoadingIndicator = UIActivityIndicatorView(frame: CGRectMake(cell.center.x, cell.center.y, 10, 10)) as UIActivityIndicatorView
          cellLoadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
          cell.addSubview(cellLoadingIndicator)
          cellLoadingIndicator.startAnimating()

          return cell
        }
        
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("plotCell") as! PlotCell
        
        cell.selectionStyle = .None
        
        cell.plot.text = post?.longDescription
        cell.plot.font = UIFont.systemFontOfSize(13)
     
        let plotLabel = cell.plot

         cell.plot.lineBreakMode = .ByWordWrapping
         cell.plot.numberOfLines = 0
        
        if plotLabel.frame.size.height > 100 {
          let heightConstraint = NSLayoutConstraint(item: plotLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
          plotLabel.addConstraint(heightConstraint)
          
          
          cell.more.setTitle("more...", forState: .Normal)
          cell.more.setTitleColor(UIColor.blueColor(), forState: .Normal)
          cell.more.addTarget(self, action: Selector("didTapMoreTextButton:"), forControlEvents: .TouchUpInside)
          
          cell.contentView.userInteractionEnabled = true

        }
        
        
        
      return cell
        
      default:
        break
      }
      
      
      return UITableViewCell()
    }
    
  
      if !reviews.isEmpty {
        let review = reviews[getCellPostIndex(indexPath.row)]
        if indexPath.row % 2 == 0 {
          let cell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopCell
          
          cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
          cell.profileImage.sd_setImageWithURL(NSURL(string: (review.pfUser!["smallProfileImage"] as! String)),
            placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
            options: SDWebImageOptions.RefreshCached, completed: { (image: UIImage!, error: NSError!, _, _) -> Void in
              if let image = image where error == nil {
                cell.profileImage.image = Toucan(image: image).maskWithEllipse().image      // crash
              }
              
          })
          cell.userName.text = review.pfUser?.username
          cell.timeSincePosted.text = review.timeSincePosted
          cell.selectionStyle = .None
          return cell
      }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewCell
        cell.selectionStyle = .None
        cell.reviewTitle.text = "- " + review.title!
        cell.reviewText.text = review.review!
        cell.rating.value = CGFloat(review.starRating!)
        cell.comments.addTarget(self, action: Selector("didTapCommentsButton:"), forControlEvents: .TouchUpInside)
        return cell
        
      }
      
      return UITableViewCell()
    }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if selectedTableViewSection == 1 {
      if let _ = YouTube.sharedInstance.currentThumbnailURL {   // check if youtube trailer info has been downloaded
        return 2
      } else {
        return 1
      }
    }
    if reviews != nil {
      return reviews.count * 2
    }
    return 0
  }
  
}



// MARK: - UITableViewDelegate
extension DetailedPostVC: UITableViewDelegate {
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    scrollView.bounces = true
  }
 
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    let headerVisualEffectView = tableView.tableHeaderView?.subviews[0]
    let headerContentView = tableView.tableHeaderView?.subviews[2]
    
    headerVisualEffectView?.transform = CGAffineTransformMakeTranslation(0, offsetY)
    headerContentView?.transform = CGAffineTransformMakeTranslation(0, offsetY - kTableHeaderViewHeight)
  }
  
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row % 2 == 0 {
      
    }
  }
  
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
      cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
    }
  }
  
}




