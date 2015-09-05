//
//  FirstViewController.swift
//  Reviews
//
//  Created by Admin on 17/06/15.
//  Copyright (c) 2015 Admin. All rights reserved.
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

extension UIViewController {
  
  func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
      let rect = CGRectMake(0, 0, size.width, size.height)
      UIGraphicsBeginImageContextWithOptions(size, false, 0)
      color.setFill()
      UIRectFill(rect)
      let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return image
  }
}


class FeedVC: UIViewController {

  @IBOutlet var tableView: UITableView!
  
  var refreshControl = UIRefreshControl()
  var dateFormat = NSDateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNib(UINib(nibName: "TopCell", bundle: nil), forCellReuseIdentifier: "TopCell")
    tableView.registerNib(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    shyNavBarManager.scrollView = self.tableView
    refresh(nil)
    
    
    
    
    /*
    var post = PFObject(className: "Post")
    let query = PFQuery(className: "Post")
    query.limit = 1
    let result = query.findObjects() as! [PFObject]
    for o in result {
      post = o
    }
    
    
    
    let newPost = PFObject(className: "Post")
    newPost["createdBy"] = PFUser.currentUser()
    newPost["posterImageURL"] = "http://is3.mzstatic.com/image/pf/us/r30/Features/cd/d3/17/dj.nsuplxar.600x600-100.jpg"
    newPost.save()
    
    
   let relation = PFUser.currentUser()!.relationForKey("feed")
    relation.addObject(newPost)
    PFUser.currentUser()!.save()
    */
    
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView?.addSubview(refreshControl)
    
    
    
    
    
    
    
    
    
    
  }
  
  
  
  
  func refresh(sender:AnyObject?) {
    
    Post.sharedInstance.feedPosts.removeAll() // temporary
    
    Post.sharedInstance.loadFeedPosts().continueWithBlock {
      (task: BFTask!) -> AnyObject! in
      if task.error == nil {
        if self.refreshControl.refreshing {
          self.refreshControl.endRefreshing()
        }
        self.tableView.reloadData()
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
  
  func getMovieInfoByITunesID(iTunesID: Int, completionHandler: ((responseJSON : JSON) -> Void)) {
    ITunesApi.lookup(iTunesID).request({ (responseString: String?, error: NSError?) -> Void in
      if error == nil, let responseString = responseString, let dataFromString = responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
        return completionHandler(responseJSON: JSON(data: dataFromString))
      }
    })
  }

  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {/*
    if segue.identifier == DID_SELECT_SEARCH_RESULT_CELL_SEGUE_IDENTIFIER,
      let vc = segue.destinationViewController as? DetailedPostVC {
        if (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!)?.isKindOfClass(TopCell) != nil) {
          vc.topCell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as? TopCell
          print(tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!))
          //   vc.contentCell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!.indexPathByAddingIndex(1)) as? ContentCell
        } else {
          vc.contentCell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as? ContentCell
          vc.topCell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!.indexPathByRemovingLastIndex()) as? TopCell
        }
    }
    }
*/
  }
  

  
// MARK: - Utility

  
  func getCellPostIndex(index: Int) -> Int {
    if index % 2 == 0 {
      return index / 2
    } else {
      return Int(floor(Double(index / 2)))
    }
  }
  
  func getTimeSincePostedfromDate(datePosted: NSDate) -> String {
    
    let ti = NSDate().timeIntervalSinceDate(datePosted)
    if ti < 2 {
      return "1 second ago"
    } else if ti < 60 {
      return "\(Int(ti)) seconds ago"
    } else if ti == 60 {
      return "1 minute ago"
    } else if ti < 3600 {
      return "\(Int(ti) / 60) minutes ago"
    } else if ti == 3600 {
      return "1 hour ago"
    } else if ti <= 3600 * 3 {
      return "\(Int(ti) / 60 / 60) hours ago"
    } else if ti < 3600 * 24 {  // today
      let comp = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: datePosted)
      return "today at \(comp.hour):\(comp.minute)"
    } else if ti < 3600 * 24 * 2 {  // yesterday
      let comp = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: datePosted)
      return "yesterday at \(comp.hour):\(comp.minute)"
    } else {
      let comp = NSCalendar.currentCalendar().components([.Month, .Day, .Hour, .Minute], fromDate: datePosted)
      return "\(dateFormat.monthSymbols[comp.month - 1]) \(comp.day) at \(comp.hour):\(comp.minute)"
    }
    
  }
  
  
  func loadImagesForOnscreenRows(){
    if (Post.sharedInstance.feedPosts.count > 0){
      let visiblePaths = tableView.indexPathsForVisibleRows!
      for indexPath in visiblePaths {
        if (indexPath.row % 2 == 0){
          let cell: TopCell = self.tableView.cellForRowAtIndexPath(indexPath) as! TopCell
          if Post.sharedInstance.feedPosts.count * 2 > indexPath.row {
            cell.profileImage.sd_setImageWithURL(
              NSURL(string: Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)].profileImageURL!),
              placeholderImage: getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.bounds.size),
              options: SDWebImageOptions.RefreshCached, completed:{(
                image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
            })
          }
        } else {
          let cell: ContentCell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContentCell
          if Post.sharedInstance.feedPosts.count * 2 > indexPath.row {
            cell.posterImage.sd_setImageWithURL(
              NSURL(string: Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)].bigPosterImageURL!),
              placeholderImage: getImageWithColor(.grayColor(), size: cell.posterImage.bounds.size)
            )
          }
        }
      }
    }
  }
  
  
  
  
}





// MARK: - UITableViewDelegate
extension FeedVC: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      performSegueWithIdentifier("showDetailedPost", sender: nil)
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
    
    
    
    if (indexPath.row % 2 == 0){
      
      let cell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopCell
      cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
      
      if Post.sharedInstance.feedPosts.count * 2 > indexPath.row {
        let post = Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)]
        cell.userName.text = post.userName
        cell.timeSincePosted.text = post.timeSincePosted
        //    cell.profileImage.image = getImageWithColor(UIColor.lightGrayColor(), size: cell.bounds.size)
        
        // Only load cached images; defer new downloads until scrolling ends
        
        
        if (tableView.dragging || tableView.decelerating) {
          SDWebImageManager.sharedManager().diskImageExistsForURL(
            NSURL(string: Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)].profileImageURL!),
            completion: { (result: Bool) -> Void in
              if result {
                cell.profileImage.sd_setImageWithURL(
                  NSURL(string: Post.sharedInstance.feedPosts[self.getCellPostIndex(indexPath.row)].profileImageURL!),
                  placeholderImage: self.getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.bounds.size),
                  options: SDWebImageOptions.RefreshCached, completed:{(
                    image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                    cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
                })
              }
          })
          return cell
        } else {
          cell.profileImage.sd_setImageWithURL(
            NSURL(string: Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)].profileImageURL!),
            placeholderImage: getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.bounds.size),
            options: SDWebImageOptions.RefreshCached, completed:{(
              image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
              cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
          })
          return cell
        }
      }
      return cell
    }
    
    // Set up the cell representing the app
    
    let cell = tableView.dequeueReusableCellWithIdentifier("ContentCell", forIndexPath: indexPath) as! ContentCell
    
    
    
    
    if Post.sharedInstance.feedPosts.count * 2 > indexPath.row {
      if (tableView.dragging || tableView.decelerating) {
        SDWebImageManager.sharedManager().cachedImageExistsForURL(
          NSURL(string: Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)].bigPosterImageURL!),
          completion: { (result: Bool) -> Void in
            if result {
              cell.posterImage.sd_setImageWithURL(
                NSURL(string: Post.sharedInstance.feedPosts[self.getCellPostIndex(indexPath.row)].bigPosterImageURL!),
                placeholderImage: self.getImageWithColor(.grayColor(), size: cell.posterImage.bounds.size)
              )
            }
          }
        )
        
        return cell
      } else {
        cell.posterImage.sd_setImageWithURL(
          NSURL(string: Post.sharedInstance.feedPosts[self.getCellPostIndex(indexPath.row)].bigPosterImageURL!),
          placeholderImage: self.getImageWithColor(.grayColor(), size: cell.posterImage.bounds.size)
        )
      }
    }
    return cell
    
    
    //  }
    
    //   return cell
    //  }
    
  }

  
  
  
  
  
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = Post.sharedInstance.feedPosts.count
    if count == 0 {
      //  return 4
    }
    return count
  }

}

// MARK: - UIScrollViewDelegate
extension FeedVC: UIScrollViewDelegate {
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if (!decelerate){
      loadImagesForOnscreenRows()
    }
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    loadImagesForOnscreenRows()
  }
  
}







