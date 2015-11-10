//
//  CommentsVC.swift
//  Moviethete
//
//  Created by Mike on 11/8/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import UIKit
import Parse
import SDWebImage
import SlackTextViewController
import Async

class CommentsVC: SLKTextViewController {

  var passedReviewObject: PFObject!
  var shouldContinueScrollingToBottom = false
  
  override init!(tableViewStyle style: UITableViewStyle) {
    super.init(tableViewStyle: UITableViewStyle.Plain)
  }
  
  required init(coder aDecoder: NSCoder!) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    textInputbar.backgroundColor = UIColor.placeholderColor()
    textInputbar.translucent = false
    
    inverted = false
    bounces = false
    
    self.tabBarController!.tabBar.translucent = false
    clearCachedText()
    textView.placeholder = "Your comment..."
    textView.slk_clearText(true)
    
    
    Comment.sharedInstance.startLoadingCommentsForReview(passedReviewObject) { () -> Void in
      self.tableView.reloadData()
      self.shouldContinueScrollingToBottom = true
      if self.tableView.numberOfRowsInSection(0) > 0 {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: UserReview.sharedInstance.commentsForSelectedReview.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
      }
    }
    
    
    
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  

  override func didPressRightButton(sender: AnyObject!) {
    let currentUser = User(theUsername: User.sharedInstance.username!, theProfileImageURL: User.sharedInstance.profileImageURL!, thePfUser: User.sharedInstance.pfUser!)
    let comment = Comment(theCreatedBy: currentUser, theText: textView.text)
    Comment.sharedInstance.uploadComment(comment, forReviewWithPfObject: passedReviewObject).continueWithBlock { (task: BFTask!) -> AnyObject! in
      if task.error == nil {
        Async.main {
          CATransaction.begin()
          CATransaction.setCompletionBlock({ () -> Void in
            self.shouldContinueScrollingToBottom = true
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: UserReview.sharedInstance.commentsForSelectedReview.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
          })
          self.tableView.beginUpdates()
          self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: UserReview.sharedInstance.commentsForSelectedReview.count - 1, inSection: 0)], withRowAnimation: .Automatic)
          self.tableView.endUpdates()
          CATransaction.commit()
        }
      }
      return nil
    }
  }
  


}


extension CommentsVC {
  
  override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    if shouldContinueScrollingToBottom {
      
      let scrollViewHeight = scrollView.frame.size.height;
      let scrollViewContentSizeHeight = scrollView.contentSize.height;
      let scrollOffset = scrollView.contentOffset.y;
      
      if (scrollOffset >= (scrollViewContentSizeHeight - scrollViewHeight) ) {
        shouldContinueScrollingToBottom = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
      } else {
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: UserReview.sharedInstance.commentsForSelectedReview.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
      }

      
      
      
    }
  }
  
  
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let comment = UserReview.sharedInstance.commentsForSelectedReview[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentCell
    cell.selectionStyle = .None
    cell.comment.text = comment.text
    cell.timeSincePosted.text = comment.timeSincePosted
    cell.profile.sd_setImageWithURL(NSURL(string: comment.createdBy.profileImageURL!), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.bounds.size), options: .AvoidAutoSetImage) { (image: UIImage!, error: NSError!, _, _) -> Void in
      if let image = image where error == nil {
        cell.profile.image = Toucan(image: image).maskWithEllipse().image
      }
    }
    

    return cell
  }
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let comments = UserReview.sharedInstance.commentsForSelectedReview {
      return comments.count
    } else {
      return 0
    }
  }
  
  
  

  
  
}



extension CommentsVC {
  
  
}






















