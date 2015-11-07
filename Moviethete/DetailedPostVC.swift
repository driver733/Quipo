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
import YouTubePlayer
import Alamofire

class DetailedPostVC: UIViewController {

  var player: YouTubePlayerView!
  var movieTrailerURL: NSURL!
  
  var tableView = UITableView()
  var tableViewSection = 0
  
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
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.registerNib(UINib(nibName: "DetailedPostMainCell", bundle: nil), forCellReuseIdentifier: "detailedPostCell")
    tableView.registerNib(UINib(nibName: "TopCell", bundle: nil), forCellReuseIdentifier: "TopCell")
    tableView.registerNib(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "reviewCell")
    tableView.registerNib(UINib(nibName: "TrailersCell", bundle: nil), forCellReuseIdentifier: "trailersCell")
    tableView.registerNib(UINib(nibName: "PlotCell", bundle: nil), forCellReuseIdentifier: "plotCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    
    self.view = tableView
    
    let headerContentView = UIView.loadFromNibNamed("DetailedPostTopView")!
    
    headerContentView.backgroundColor = UIColor.clearColor()
    headerContentView.frame = CGRectMake(0, 64, self.view.frame.width, 180)
    headerContentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    
    for subView in headerContentView.subviews {
      
      switch subView.restorationIdentifier! {
      case "moviePoster":
        let moviePoster = subView as! UIImageView
        moviePoster.sd_setImageWithURL(NSURL(string: (passedPost?.standardPosterImageURL)!), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: moviePoster.frame.size))
        
      case "segmCtrl":
        let segControl = subView as! UISegmentedControl
        segControl.addTarget(self, action: Selector("didChangeSection:"), forControlEvents: .AllEvents)
      case "movieTitle":
        let movieName = subView as! UILabel
        movieName.text = passedPost?.movieTitle
      case "+fav":
        let button = subView as! UIButton
        button.addTarget(self, action: Selector("didTapFavButton:"), forControlEvents: .TouchUpInside)
      case "+watched":
        let button = subView as! UIButton
        button.addTarget(self, action: Selector("didTapWatchedButton:"), forControlEvents: .TouchUpInside)
      case "movieRating":
        let movieRating = subView as! HCSStarRatingView
        movieRating.backgroundColor = UIColor.clearColor()
        movieRating.value = CGFloat((passedPost?.rating)!) // change to average rating amongst friends
        movieRating.userInteractionEnabled = false
        
      default:
        break
        
      }
      
    }
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
    visualEffectView.frame = headerContentView.frame
    
    visualEffectView.addSubview(headerContentView)
    
    tableView.tableHeaderView = visualEffectView
    
    self.navigationController?.navigationBar.shadowImage = (getImageWithColor(UIColor.placeholderColor(), size: (CGSizeMake(0.35, 0.35))))
    
    self.title = passedPost!.movieTitle!
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    let gesture = UITapGestureRecognizer(target: self, action: "didTapPlayer:")
    self.view.addGestureRecognizer(gesture)
    gesture.cancelsTouchesInView = false
    
  }

  
  
  
  override func viewWillAppear(animated: Bool) {
    
    if passedColor != nil && textColor != nil {
      self.transitionCoordinator()?.animateAlongsideTransition({
        (context: UIViewControllerTransitionCoordinatorContext) -> Void in
        if self.navigationController!.viewControllers[0].isKindOfClass(SearchVC) {
          self.navigationController?.navigationBar.subviews[1].hidden = true           // hide search bar if it is present
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
    
    if tableViewSection == 0 {
      
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
  
  
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - Buttons
  
  
  
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
    
  }
  
  func didTapWatchedButton(sender: UIButton) {
    
  }
  
  
  func didChangeSection(sender: UISegmentedControl ) {
    switch sender.selectedSegmentIndex {
      
    case 0:
      tableViewSection = 0
      tableView.reloadData()
    case 1:
      tableViewSection = 1
      tableView.reloadData()
      tableView.contentSize.height += 20
      if player == nil {
        YouTube.sharedInstance.getMovieTrailerWithMovieTitle((passedPost?.movieTitle)!, releasedIn: (passedPost?.releaseYear)!).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
          
          let videoInfo = task.result as! [String]
          let trailerId = videoInfo[0]
          let thumbnailURL = videoInfo[1]
          let videoDuration = videoInfo[2]
          let trailerCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TrailersCell
          trailerCell.videoLength.text = videoDuration
    //      trailersCell.videoLength.text =
          trailerCell.thumbnail.sd_setImageWithURL(NSURL(string: thumbnailURL), placeholderImage: self.getImageWithColor(UIColor.placeholderColor(), size: CGSizeMake(trailerCell.bounds.width, trailerCell.bounds.height)), completed: { (image: UIImage!, error: NSError!, _, _) -> Void in
            if image != nil && error == nil {
              let img = self.getImageWithColor(UIColor.redColor(), size: CGSizeMake(30, 30))
              let view = UIImageView(frame: CGRectMake(0, 0, 30, 30))
              view.image = img
            //  trailersCell.thumbnail.addSubview(view)
              
            }
          })
          self.player = YouTubePlayerView(frame: self.view.frame)
          self.player.delegate = self
          self.player.loadVideoID(trailerId)
          
          
          return nil
        })
      }
      
    default: break
    }
  }

  
  

  func didTapPlayer(press: UITapGestureRecognizer) {
    
    if press.state == .Ended {
      
      
      let location = press.locationInView(tableView)
      let path = tableView.indexPathForRowAtPoint(location)
      if path?.row == 0  {
        if tableViewSection == 1 {
          let cell = tableView.cellForRowAtIndexPath(path!) as! TrailersCell
          
          var viewPoint = cell.thumbnail.convertPoint(location, fromView: tableView)
          if cell.thumbnail.pointInside(viewPoint, withEvent: nil) {
            
            if player.ready {
              player.play()
            }
          
          }

          

        }

      
      }
      
   
      
    }
  }
  
  
  
  // MARK: - Utility
  
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
  
  


  
  
  

  
  
  
}


// MARK: - UITableViewDataSource
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
    
    
    if tableViewSection == 1 {
      
      switch indexPath.row {
        
      case 0:
        let cell = tableView.dequeueReusableCellWithIdentifier("trailersCell") as! TrailersCell
        cell.selectionStyle = .None
        return cell
        
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("plotCell") as! PlotCell
        
        cell.selectionStyle = .None
        
        cell.plot.text = passedPost?.longDescription
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
    
  
      if !UserReview.sharedInstance.movieReviewsForSelectedMovie.isEmpty {
        let review = UserReview.sharedInstance.movieReviewsForSelectedMovie[getCellPostIndex(indexPath.row - 1)]
        if indexPath.row % 2 == 0 {
          let cell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopCell
          
          cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
          cell.profileImage.sd_setImageWithURL(NSURL(string: (review.pfUser!["smallProfileImage"] as! String)),
            placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
            options: SDWebImageOptions.RefreshCached, completed: { (image: UIImage!, erro: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
              cell.profileImage.image = Toucan(image: image).maskWithEllipse().image      // crash
              
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
    if tableViewSection == 1 {
      return 2
    }
    return UserReview.sharedInstance.movieReviewsForSelectedMovie.count * 2
  }
  
  
  
  
}




// MARK: - UITableViewDelegate
extension DetailedPostVC: UITableViewDelegate {
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    scrollView.bounces = true
  }
 
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    let headerContentView = tableView.tableHeaderView?.subviews[0]
    let headerVisualEffectView = tableView.tableHeaderView?.subviews[2]
    headerContentView?.transform = CGAffineTransformMakeTranslation(0, offsetY + 64)
    headerVisualEffectView?.transform = CGAffineTransformMakeTranslation(0, offsetY)
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
      cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
    }
  }
  
}

// MARK: - YouTubePlayerDelegate
extension DetailedPostVC: YouTubePlayerDelegate {
  func playerReady(videoPlayer: YouTubePlayerView) {
    
  }
  func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
   
  }
  func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
    
  }
}






