//
//  FirstViewController.swift
//  Reviews
//
//  Created by Mikhail Yakushin on 17/06/15.
//  Copyright (c) 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
import TLYShyNavBar
import Async
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Parse
import SDWebImage
import ITunesSwift
import VK_ios_sdk
import Alamofire
import SwiftLocation
import Bolts


class FeedVC: UIViewController {

  var tableView = UITableView()
  
  var refreshControl = UIRefreshControl()
  var dateFormat = NSDateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view = tableView
    tableView.registerNib(UINib(nibName: "TopCell", bundle: nil), forCellReuseIdentifier: "TopCell")
    tableView.registerNib(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    
    tableView.addSubview(refreshControl)
    
    shyNavBarManager.scrollView = self.tableView
  
   // refreshControl.attributedTitle = NSAttributedString(string: "Last updated at:")
    refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    self.navigationController?.navigationBar.barTintColor = UIColor.quipoColor()
    
    self.automaticallyAdjustsScrollViewInsets = false
    
    self.refreshControl.beginRefreshing()
    self.refresh(nil)
  }
  
  
  override func viewDidAppear(animated: Bool) {
    NSNotificationCenter.defaultCenter().postNotificationName("feedViewDidAppear", object: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    self.title = "Feed"
    self.navigationController?.navigationBar.translucent = true
    self.transitionCoordinator()?.animateAlongsideTransition({
      (context: UIViewControllerTransitionCoordinatorContext) -> Void in
      if self.navigationController!.viewControllers[0].isKindOfClass(SearchVC) {
        self.navigationController?.navigationBar.subviews[1].hidden = true             // hide search bar if it is present
      }
      self.navigationController?.navigationBar.barTintColor = UIColor.quipoColor()
      self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
      self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
      },
      completion: { (completionContext: UIViewControllerTransitionCoordinatorContext) -> Void in
//        self.navigationController?.navigationBar.barTintColor = UIColor.quipoColor()
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    })

  }
  
  
  func refresh(sender: AnyObject?) {
    UserSingleton.getSharedInstance().loadFeedPosts().continueWithBlock {
  (task: BFTask!) -> AnyObject! in
    if task.error == nil {
      Async.main {
        self.refreshControl.endRefreshing()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.reloadData()
      }
      return nil
    } else {
      // process error
      return nil
    }
  }
  
    
  }
  

  
  // This function will be called when the Dynamic Type user setting changes (from the system Settings app)
  func contentSizeCategoryChanged(notification: NSNotification) {
    tableView.reloadData()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  

// MARK: - Utility

  
  func getCellPostIndex(index: Int) -> Int {
    if index % 2 == 0 {
      return index / 2
    } else {
      return Int(floor(Double(index / 2)))
    }
  }
  
  func loadImagesForOnscreenRows() {
    
    if (UserSingleton.getSharedInstance().feedPosts.count > 0){
      let visiblePaths = tableView.indexPathsForVisibleRows!
      for indexPath in visiblePaths {
        if (indexPath.row % 2 == 0) {
          let cell: TopCell = self.tableView.cellForRowAtIndexPath(indexPath) as! TopCell   // crash
          if UserSingleton.getSharedInstance().feedPosts.count * 2 > indexPath.row {
            cell.profileImage.sd_setImageWithURL(
              NSURL(string: UserSingleton.getSharedInstance().feedPosts[getCellPostIndex(indexPath.row)].author!.profileImageURL!),
              placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
              options: SDWebImageOptions.RefreshCached,
              completed:{
                (image: UIImage!, error: NSError!, _, _) -> Void in
                if let image = image where error == nil {
                  cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
                }
              }
            )
          }
        } else {
          let cell: ContentCell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContentCell
          if UserSingleton.getSharedInstance().feedPosts.count * 2 > indexPath.row {
            if let bigPosterImage = UserSingleton.getSharedInstance().feedPosts[getCellPostIndex(indexPath.row)].standardPosterImageURL {
              cell.posterImage.sd_setImageWithURL(
                NSURL(string: bigPosterImage),
                placeholderImage: getImageWithColor(.placeholderColor(), size: cell.posterImage.bounds.size)
              )
            }
          }
        }
      }
    }
  }
  
  
}





// MARK: - UITableViewDelegate
extension FeedVC: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row % 2 == 0 {
      let selectedUser = UserSingleton.getSharedInstance().feedPosts[getCellPostIndex(indexPath.row)].author!
      let vc = ProfileVC(theUser: selectedUser)
      self.navigationController?.pushViewController(vc, animated: true)
    } else {
      let post = UserSingleton.getSharedInstance().feedPosts[getCellPostIndex((tableView.indexPathForSelectedRow?.row)!)]
      let posterImage = (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as! ContentCell).posterImage.image!
      let colors = primaryPosterImageColorAndtextColor(posterImage)
      let vc = DetailedPostVC(thePost: post, theNavBarBackgroundColor: colors.primaryColor, theNavBarTextColor: colors.inferredTextColor)
      self.navigationController?.pushViewController(vc, animated: true)
      BFTask(forCompletionOfAllTasksWithResults: [
        UserMedia.userMediaInfoForMovieWithTrackID(post.trackID!),
         Post.sharedInstance.loadMovieReviewsForMovie((post.trackID)!)
        ]).continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
          let tasks = task.result as! NSArray
          vc.userMediaInfo = tasks[0] as? UserMedia
          vc.reviews = tasks[1] as! [UserReview]
          return nil
        })
     
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
}


// MARK: - UITableViewDataSource
extension FeedVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
   
    
    /*
    if (indexPath.row == 0)
    {
    let cell:TopCell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopCell
    cell.userName.text = "Loading..."
    }
    else
    {
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
    {
    */
    
    
    if (indexPath.row % 2 == 0) {
      
      let cell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopCell
      cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
      
      if UserSingleton.getSharedInstance().feedPosts.count * 2 > indexPath.row {
        let post = UserSingleton.getSharedInstance().feedPosts[getCellPostIndex(indexPath.row)]
        cell.userName.text = post.userName
        cell.timeSincePosted.text = post.timeSincePosted
        
  
        // Only load cached images; defer new downloads until scrolling ends
        
        
        if (tableView.dragging || tableView.decelerating) {
          SDWebImageManager.sharedManager().diskImageExistsForURL(
            NSURL(string: UserSingleton.getSharedInstance().feedPosts[getCellPostIndex(indexPath.row)].author!.profileImageURL!),
            completion: { (result: Bool) -> Void in
              if result {
                cell.profileImage.sd_setImageWithURL(
                  NSURL(string: UserSingleton.getSharedInstance().feedPosts[self.getCellPostIndex(indexPath.row)].author!.profileImageURL!),
                  placeholderImage: self.getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
                  options: SDWebImageOptions.RefreshCached, completed:{(
                    image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                    if image != nil && error == nil {
                      cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
                    }
                })
              } else {
                cell.profileImage.image = self.getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size)
              }
          })
          return cell
        } else {
          cell.profileImage.sd_setImageWithURL(
            NSURL(string: UserSingleton.getSharedInstance().feedPosts[getCellPostIndex(indexPath.row)].author!.profileImageURL!),
            placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
            options: SDWebImageOptions.RefreshCached, completed:{(
              image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
              if error == nil && image != nil {
                cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
              }
          })
          return cell
        }
      }
    

      return cell
    }
    
    
    let cell = tableView.dequeueReusableCellWithIdentifier("ContentCell", forIndexPath: indexPath) as! ContentCell
    
    if UserSingleton.getSharedInstance().feedPosts.count * 2 > indexPath.row {
      let post = UserSingleton.getSharedInstance().feedPosts[getCellPostIndex(indexPath.row)]
      cell.rating.value = CGFloat(post.rating!)
      cell.reviewTitle.text = post.reviewTitle!
      cell.reviewText.text = post.review!

      if (tableView.dragging || tableView.decelerating) {
        SDWebImageManager.sharedManager().cachedImageExistsForURL(
          NSURL(string: UserSingleton.getSharedInstance().feedPosts[getCellPostIndex(indexPath.row)].standardPosterImageURL!),
          completion: { (result: Bool) -> Void in
            if result {
                cell.posterImage.sd_setImageWithURL(
                  NSURL(string: UserSingleton.getSharedInstance().feedPosts[self.getCellPostIndex(indexPath.row)].standardPosterImageURL!),
                  placeholderImage: self.getImageWithColor(.placeholderColor(), size: cell.posterImage.bounds.size)
                )
//              cell.posterImage.sd_setImageWithURL(
//                NSURL(string: UserSingleton.getSharedInstance().feedPosts[self.getCellPostIndex(indexPath.row)].bigPosterImageURL!),
//                placeholderImage: self.getImageWithColor(.placeholderColor(), size: cell.posterImage.bounds.size), options: SDWebImageOptions.AvoidAutoSetImage, completed: { (image: UIImage!, error: NSError!, _, _) -> Void in
//                  cell.posterImage.image = Toucan(image: image).resize(cell.posterImage.bounds.size, fitMode: Toucan.Resize.FitMode.Scale).image
//              })
            } else {
              cell.posterImage.image = self.getImageWithColor(UIColor.placeholderColor(), size: cell.posterImage.bounds.size)
            }
          }
        )
        return cell
        
      } else {
        cell.posterImage.sd_setImageWithURL(
          NSURL(string: UserSingleton.getSharedInstance().feedPosts[self.getCellPostIndex(indexPath.row)].standardPosterImageURL!),
          placeholderImage: self.getImageWithColor(.placeholderColor(), size: cell.posterImage.bounds.size)
        )
//        cell.posterImage.sd_setImageWithURL(
//          NSURL(string: UserSingleton.getSharedInstance().feedPosts[self.getCellPostIndex(indexPath.row)].bigPosterImageURL!),
//          placeholderImage: self.getImageWithColor(.placeholderColor(), size: cell.posterImage.bounds.size), options: SDWebImageOptions.AvoidAutoSetImage, completed: { (image: UIImage!, error: NSError!, _, _) -> Void in
//            cell.posterImage.image = Toucan(image: image).resize(cell.posterImage.bounds.size, fitMode: Toucan.Resize.FitMode.Scale).image
//        })
        return cell
      }
    }
    
 
    return cell
  }

  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = UserSingleton.getSharedInstance().feedPosts.count * 2
    if count == 0 {
      //  return 4
    }
    return count
  }

}

// MARK: - UIScrollViewDelegate
extension FeedVC: UIScrollViewDelegate {
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if (!decelerate) {
      loadImagesForOnscreenRows()
    }
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    loadImagesForOnscreenRows()
  }
  
}







