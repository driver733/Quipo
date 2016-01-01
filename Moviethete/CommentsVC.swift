//
//  CommentsVC.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 11/8/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
import Parse
import SDWebImage
import SlackTextViewController
import Async

class CommentsVC: SLKTextViewController {

  var passedReview: UserReview!
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
    
    passedReview.loadComments().continueWithBlock { (task: BFTask) -> AnyObject? in
      self.tableView.reloadData()
      self.shouldContinueScrollingToBottom = true
      if self.tableView.numberOfRowsInSection(0) > 0 {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.passedReview.comments.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
      }
      return nil
    }
    
   
    
    
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  

  override func didPressRightButton(sender: AnyObject!) {
    let currentUser = UserSingleton.getSharedInstance()
    let comment = Comment(theCreatedBy: currentUser, theText: textView.text)
    comment.uploadForReviewPFObject(passedReview.pfObject).continueWithBlock { (task: BFTask!) -> AnyObject! in
      if task.error == nil {
        Async.main {
          CATransaction.begin()
          CATransaction.setCompletionBlock({ () -> Void in
            self.shouldContinueScrollingToBottom = true
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.passedReview.comments.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
          })
          self.tableView.beginUpdates()
          self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.passedReview.comments.count - 1, inSection: 0)], withRowAnimation: .Automatic)
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
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: passedReview.comments.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
      }

      
      
      
    }
  }
  
  
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let comment = passedReview.comments[indexPath.row]
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
    if passedReview.comments != nil {
      return passedReview.comments.count
    } else {
      return 0
    }
  }
  
  
  

  
  
}








