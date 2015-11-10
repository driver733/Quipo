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
  
  var numberOfReviews: UILabel!
  var starred: UIButton!
  var watched: UIButton!
 // var avgMovieRating: HCSStarRatingView!
  
  var tableView = UITableView()
  var selectedTableViewSection = 0
  var firstSectionContentOffset: CGPoint!
  var secondSectionContentOffset: CGPoint!
  
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
    
    self.automaticallyAdjustsScrollViewInsets = true

    
    setupTableHeaderView()
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    self.navigationController?.navigationBar.shadowImage = (getImageWithColor(UIColor.placeholderColor(), size: (CGSizeMake(0.35, 0.35))))
    self.title = passedPost!.movieTitle!
    
    let gesture = UITapGestureRecognizer(target: self, action: "didTapSuperview:")
    self.view.addGestureRecognizer(gesture)
    gesture.cancelsTouchesInView = false
    
    
    
    
    BFTask(forCompletionOfAllTasks: [
      Post.sharedInstance.loadMovieReviewsForMovie((passedPost?.trackID)!),
      UserMedia.sharedInstance.startLoadingUserMediaInfoForMovie((passedPost?.trackID)!, andUser: PFUser.currentUser()!)
      ]).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        
        if self.userHasReviewForSelectedMovie() {
          self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "addPost"), animated: false)
        } else {
          self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "addPost"), animated: false)
        }
        self.numberOfReviews.text = "(\(UserReview.sharedInstance.movieReviewsForSelectedMovie.count))"
        // self.avgMovieRating.value = CGFloat(UserReview.sharedInstance.avgMovieRatingForSelectedMovie)
        
        if UserReview.sharedInstance.userMediaInfoForSelectedMovie.isWatched {
            self.watched.setTitle("Watched", forState: .Normal)
            self.watched.setTitleColor(UIColor.greenColor(), forState: .Normal)
        }
        if UserReview.sharedInstance.userMediaInfoForSelectedMovie.isStarred {
          self.starred.setTitle("Starred", forState: .Normal)
          self.starred.setTitleColor(UIColor.greenColor(), forState: .Normal)
        }
        
        self.putFeedReviewToTheBeginning()
        self.tableView.reloadData()
        
        
        
        return nil

    }
    
   
    
    
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
  
  
  
  func didTapCommentsButton(sender: UIButton) {

    var parentView = sender.superview!
    while (!(parentView.isKindOfClass(ReviewCell)) ) {
      parentView = parentView.superview!
    }
    
    
    let cell = parentView as! ReviewCell
    
    let vc = CommentsVC(tableViewStyle: .Plain)
    vc.passedReviewObject = UserReview.sharedInstance.movieReviewsForSelectedMovie[getCellPostIndex((tableView.indexPathForCell(cell)?.row)!)].pfObject!
    
    
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
    if UserReview.sharedInstance.userMediaInfoForSelectedMovie.isStarred {
      UserMedia.sharedInstance.markMovie((passedPost?.trackID)!, AsStarred: false, pfObject: UserReview.sharedInstance.userMediaInfoForSelectedMovie.pfObject).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        sender.setTitle("+ Starred", forState: .Normal)
        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
        return nil
      }
    } else {
      UserMedia.sharedInstance.markMovie((passedPost?.trackID)!, AsStarred: true, pfObject: UserReview.sharedInstance.userMediaInfoForSelectedMovie.pfObject).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        sender.setTitle("Starred", forState: .Normal)
        sender.setTitleColor(UIColor.greenColor(), forState: .Normal)
        return nil
      }
    }
  }
  
  func didTapWatchedButton(sender: UIButton) {
    if UserReview.sharedInstance.userMediaInfoForSelectedMovie.isWatched {
      UserMedia.sharedInstance.markMovie((passedPost?.trackID)!, AsWatched: false, pfObject: UserReview.sharedInstance.userMediaInfoForSelectedMovie.pfObject).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        sender.setTitle("+ Watched", forState: .Normal)
        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
        return nil
      }
    } else {
      UserMedia.sharedInstance.markMovie((passedPost?.trackID)!, AsWatched: true, pfObject: UserReview.sharedInstance.userMediaInfoForSelectedMovie.pfObject).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
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

      if player == nil {
        YouTube.sharedInstance.getMovieTrailerWithMovieTitle((passedPost?.movieTitle)!, releasedIn: (passedPost?.releaseYear)!).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
          
          let videoInfo = task.result as! [String]
          let trailerId = videoInfo[0]
          let thumbnailURL = videoInfo[1]
          let videoDuration = videoInfo[2]
          
          YouTube.sharedInstance.currentTrailerId = trailerId
          YouTube.sharedInstance.currentThumbnailURL = thumbnailURL
          YouTube.sharedInstance.currenVideoDuration = videoDuration
          
          self.player = YouTubePlayerView(frame: self.view.frame)
          self.player.delegate = self
          self.player.loadVideoID(trailerId)
          
          self.tableView.reloadData()
                   
          return nil
        })
      } else {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        setContentOffset()
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

      let point = (tableView.tableHeaderView?.subviews[2])!.convertPoint(location, fromView: tableView)
      if (tableView.tableHeaderView?.subviews[2])!.pointInside(point, withEvent: nil) {
        for subView in (tableView.tableHeaderView?.subviews[2].subviews)! {
          
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
            
            if player.ready {
              player.play()
            }
          
          }

          

        }

      
      }
      
   
      
    }
  }
  
  
  
  // MARK: - Utility
  
  
  
  func setupTableHeaderView() {
    let headerContentView = UIView.loadFromNibNamed("DetailedPostTopView")!
    
    headerContentView.backgroundColor = UIColor.clearColor()
    headerContentView.frame = CGRectMake(0, 64, self.view.frame.width, 180)
    headerContentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    
    for subView in headerContentView.subviews {
      
      switch subView.restorationIdentifier! {
        
      case "moviePoster":
        let moviePoster = subView as! UIImageView
        moviePoster.sd_setImageWithURL(NSURL(string: (passedPost?.standardPosterImageURL)!), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: moviePoster.frame.size))

      case "movieTitle":
        let movieName = subView as! UILabel
        movieName.text = passedPost?.movieTitle
        
      case "+fav":
        let button = subView as! UIButton
        starred = button
        
      case "+watched":
        let button = subView as! UIButton
        watched = button
        
      case "numberOfReviews":
        let label = subView as! UILabel
        numberOfReviews = label
        label.font = label.font.fontWithSize(12)
        
      case "movieRating":
        let movieRating = subView as! HCSStarRatingView
        movieRating.backgroundColor = UIColor.clearColor()
        movieRating.value = CGFloat((passedPost?.rating)!) // change to average rating amongst friends
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
  
    if selectedTableViewSection == 1 {
      
      switch indexPath.row {
        
      case 0:
        let cell = tableView.dequeueReusableCellWithIdentifier("trailersCell") as! TrailersCell
        cell.selectionStyle = .None
        cell.videoLength.font = cell.videoLength.font.fontWithSize(13)
        cell.videoLength.text = YouTube.sharedInstance.currenVideoDuration
        cell.videoType.font = cell.videoType.font.fontWithSize(13)
        cell.thumbnail.sd_setImageWithURL(NSURL(string: YouTube.sharedInstance.currentThumbnailURL), placeholderImage: self.getImageWithColor(UIColor.placeholderColor(), size: cell.bounds.size), completed: { (image: UIImage!, error: NSError!, _, _) -> Void in
          if image != nil && error == nil {
            let img = self.getImageWithColor(UIColor.redColor(), size: CGSizeMake(30, 30))
            let view = UIImageView(frame: CGRectMake(0, 0, 30, 30))
            view.image = img
          }
        })

        
        
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
        let review = UserReview.sharedInstance.movieReviewsForSelectedMovie[getCellPostIndex(indexPath.row)]
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
    let headerVisualEffectView = tableView.tableHeaderView?.subviews[0]
    let headerContentView = tableView.tableHeaderView?.subviews[2]
    
    headerVisualEffectView?.transform = CGAffineTransformMakeTranslation(0, offsetY + 64)
    headerContentView?.transform = CGAffineTransformMakeTranslation(0, offsetY)
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






