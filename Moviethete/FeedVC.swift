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
import VK_ios_sdk


extension UIView {
  class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
    return UINib(
      nibName: nibNamed,
      bundle: bundle
      ).instantiateWithOwner(nil, options: nil)[0] as? UIView
  }
}

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
  
  func getPrimaryPosterImageColorAndtextColor(posterImage: UIImage) -> [UIColor] {
    
    var returnColors = [UIColor]()
    let uiColor = posterImage.getColors(CGSizeMake(50, 50)).primaryColor
    
    let newColor = testColor(uiColor)
    
    if newColor != "normal" {
      let backgroundUiColor = posterImage.getColors(CGSizeMake(50, 50)).backgroundColor
      let testBackroundColor = testColor(backgroundUiColor)
      
      if testBackroundColor != "normal" {
        
        if testBackroundColor == "black" {
          returnColors.append(UIColor.whiteColor())
          returnColors.append(backgroundUiColor)
          return returnColors
          
        } else {
          returnColors.append(UIColor.blackColor())
          returnColors.append(backgroundUiColor)
          return returnColors
        }
        
      } else {
        returnColors.append(UIColor.whiteColor())
        returnColors.append(backgroundUiColor)
        return returnColors
      }
      
    } else {
      returnColors.append(UIColor.whiteColor())
      returnColors.append(uiColor)
      return returnColors
    }
    
  }
  
   func testColor(theColor: UIColor) -> String {
    
    let color = theColor.CGColor
    let numComponents = CGColorGetNumberOfComponents(color)
    
    if numComponents == 4 {
      let components = CGColorGetComponents(color)
      let red = components[0]
      let green = components[1]
      let blue = components[2]
      
      if red < 0.3 && green < 0.3 && blue < 0.3 {
        return "black"
      } else if red > 0.7 && green > 0.7 && blue > 0.7 {
        return "white"
      } else {
        return "normal"
      }
    }
    return ""
  }
  
  
  
}


extension UIColor {
  
  convenience init(r: CGFloat, g: CGFloat, b: CGFloat)  {
    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
  }
  
   class func placeholderColor() -> UIColor {
    return UIColor(r: 240, g: 240, b: 240)
  }
  
  class func quipoColor() -> UIColor {
    return UIColor(r: 103, g: 80, b: 182)
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
    
  
   // refreshControl.attributedTitle = NSAttributedString(string: "Last updated at:")
    refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    tableView?.addSubview(refreshControl)

    
    
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    self.navigationController?.navigationBar.barTintColor = UIColor.quipoColor()
    
    
    
    UserSingelton.sharedInstance.loadFollowFriendsData()
    
    
    
    refresh(nil)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  }
  
  
  override func viewWillAppear(animated: Bool) {
    self.title = "Feed"
    
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
        self.navigationController?.navigationBar.barTintColor = UIColor.quipoColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    })

  }
  
  
  func refresh(sender: AnyObject?) {


  Post.sharedInstance.startLoadingFeedPosts().continueWithBlock {
  (task: BFTask!) -> AnyObject! in
    if task.error == nil {
      
      Async.main {
        if self.refreshControl.refreshing {
          self.refreshControl.endRefreshing()
        }
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
  

  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if let vc = segue.destinationViewController as? DetailedPostVC {
      let post = Post.sharedInstance.feedPosts[getCellPostIndex((tableView.indexPathForSelectedRow?.row)!)]
      vc.passedPost = post
      let posterImage = (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as! ContentCell).posterImage.image!
      let resizedPosterImage = Toucan(image: posterImage).resize(CGSizeMake(50, 50), fitMode: Toucan.Resize.FitMode.Scale).image
      let colors = getPrimaryPosterImageColorAndtextColor(resizedPosterImage)
      vc.passedColor = colors[1]
      vc.textColor = colors[0]
    }
    
    
    /*
    if segue.identifier == DID_SELECT_SEARCH_RESULT_CELL_SEGUE_IDENTIFIER,
      let vc = segue.destinationViewController as? DetailedPostVC {
        if (tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!)?.isKindOfClass(TopCell) != nil) {
          vc.topCell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as? TopCell
    
             vc.contentCell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!.indexPathByAddingIndex(1)) as? ContentCell
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
  
  
  
  
  func loadImagesForOnscreenRows() {
    
    if (Post.sharedInstance.feedPosts.count > 0){
      let visiblePaths = tableView.indexPathsForVisibleRows!
      for indexPath in visiblePaths {
        if (indexPath.row % 2 == 0) {
          let cell: TopCell = self.tableView.cellForRowAtIndexPath(indexPath) as! TopCell
          if Post.sharedInstance.feedPosts.count * 2 > indexPath.row {
            cell.profileImage.sd_setImageWithURL(
              NSURL(string: Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)].profileImageURL!),
              placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
              options: SDWebImageOptions.RefreshCached,
              completed:{
                (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
                // crash
              }
            )
          }
        } else {
          let cell: ContentCell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContentCell
          if Post.sharedInstance.feedPosts.count * 2 > indexPath.row {
            if let bigPosterImage = Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)].bigPosterImageURL {
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
    if indexPath.row % 2 != 0 {                                     // content cell
      performSegueWithIdentifier("showDetailedPost", sender: nil)
      tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
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
      cell.selectionStyle = .None
      cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
      
      if Post.sharedInstance.feedPosts.count * 2 > indexPath.row {
        let post = Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)]
        cell.userName.text = post.userName
        cell.timeSincePosted.text = post.timeSincePosted
        
        
        // Only load cached images; defer new downloads until scrolling ends
        
        
        if (tableView.dragging || tableView.decelerating) {
          SDWebImageManager.sharedManager().diskImageExistsForURL(
            NSURL(string: Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)].profileImageURL!),
            completion: { (result: Bool) -> Void in
              if result {
                cell.profileImage.sd_setImageWithURL(
                  NSURL(string: Post.sharedInstance.feedPosts[self.getCellPostIndex(indexPath.row)].profileImageURL!),
                  placeholderImage: self.getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
                  options: SDWebImageOptions.RefreshCached, completed:{(
                    image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                    cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
                })
              } else {
                cell.profileImage.image = self.getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size)
              }
          })
          return cell
        } else {
          cell.profileImage.sd_setImageWithURL(
            NSURL(string: Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)].profileImageURL!),
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
    
    if Post.sharedInstance.feedPosts.count * 2 > indexPath.row {
      let post = Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)]
      cell.rating.value = CGFloat(post.rating!)
      cell.reviewTitle.text = "- " + post.reviewTitle!
      cell.reviewText.text = post.review!

      if (tableView.dragging || tableView.decelerating) {
        SDWebImageManager.sharedManager().cachedImageExistsForURL(
          NSURL(string: Post.sharedInstance.feedPosts[getCellPostIndex(indexPath.row)].bigPosterImageURL!),
          completion: { (result: Bool) -> Void in
            if result {
                cell.posterImage.sd_setImageWithURL(
                  NSURL(string: Post.sharedInstance.feedPosts[self.getCellPostIndex(indexPath.row)].bigPosterImageURL!),
                  placeholderImage: self.getImageWithColor(.placeholderColor(), size: cell.posterImage.bounds.size)
                )
            } else {
              cell.posterImage.image = self.getImageWithColor(UIColor.placeholderColor(), size: cell.posterImage.bounds.size)
            }
          }
        )
        return cell
        
      } else {
        cell.posterImage.sd_setImageWithURL(
          NSURL(string: Post.sharedInstance.feedPosts[self.getCellPostIndex(indexPath.row)].bigPosterImageURL!),
          placeholderImage: self.getImageWithColor(.placeholderColor(), size: cell.posterImage.bounds.size)
        )
        return cell
      }
    }
    
 
    return cell
  }

  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = Post.sharedInstance.feedPosts.count * 2
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







