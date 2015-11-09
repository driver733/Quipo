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

class CommentsVC: SLKTextViewController {

  var passedReviewObject: PFObject!
  
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
    inverted = false
    
    
    textView.placeholder = "Your comment..."
    
    
    
    Comment.sharedInstance.startLoadingCommentsForReview(passedReviewObject) { () -> Void in
      self.tableView.reloadData()
     // print(UserReview.sharedInstance.commentsForSelectedReview)
    }

    
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
    

  

}


extension CommentsVC {
  
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






















