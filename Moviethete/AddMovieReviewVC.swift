//
//  AddMovieReviewVC.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 9/3/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
import Bolts
import HCSStarRatingView
import SwiftValidator
import Parse

class AddMovieReviewVC: UIViewController {
  
  var post = Post()
  var passedReview: UserReview? = nil

  var tableView = UITableView()
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      tableView.dataSource = self
      tableView.registerNib(UINib(nibName: "StarRating", bundle: nil), forCellReuseIdentifier: "StarRating")
      tableView.registerNib(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
      tableView.registerNib(UINib(nibName: "ReviewTextCell", bundle: nil), forCellReuseIdentifier: "reviewTextCell")
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 44.0
      
      self.view = tableView

      self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "dismiss"), animated: true)
      self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Done, target: self, action: Selector("didEndEditingReview")), animated: true)
      
      
      if passedReview != nil {
        self.title = "Edit Review"
      } else {
        self.title = "Write a Review"
      }
      
      
      
    }
  
  
  
  func didEndEditingReview() {
    
    
    if ((tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TitleCell).reviewTitle.text!.isEmpty) {
      let alert = UIAlertController(title: "Missing title", message: "Please enter title", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
      return
    }
    
    
    
    if ((tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! ReviewTextCell).review.text.isEmpty ||
      (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! ReviewTextCell).review.text == "Tell your friends what you think about the movie...") {
        let alert = UIAlertController(title: "Missing review", message: "Please enter your review", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        return
    }
    
    
    let starRatingCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! StarRating
    let reviewTitleCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TitleCell
    let reviewCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! ReviewTextCell
    
    if passedReview != nil {
      let reviewObject =  PFObject(withoutDataWithClassName: "Post", objectId: passedReview?.pfObject?.objectId!)
  
      let userReview = NSMutableArray()
      userReview.addObject(Int(starRatingCell.rating.value))
      userReview.addObject(reviewTitleCell.reviewTitle.text!)
      userReview.addObject(reviewCell.review.text)
  
      reviewObject["userReview"] = userReview
      reviewObject.saveInBackground().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
        self.dismissViewControllerAnimated(true, completion: nil)
        return nil
      })
    } else {
      UserReview.sharedInstance.uploadReview(post, rating: Int(starRatingCell.rating.value), reviewTitle: reviewTitleCell.reviewTitle.text!, review: reviewCell.review.text).continueWithBlock { (task: BFTask!) -> AnyObject! in
        self.dismissViewControllerAnimated(true, completion: nil)
        return nil
      }
    }
  }
  
  
 
    
  
    
    
  
  
  func dismiss() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

}

extension AddMovieReviewVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch indexPath.row {
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("StarRating", forIndexPath: indexPath) as! StarRating
      if let currentUserReview = passedReview {
        cell.rating.value = CGFloat(currentUserReview.starRating!)
      } else {
        cell.rating.value = 1
      }
      cell.selectionStyle = .None
      return cell
    case 1:
      let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as! TitleCell
      if let currentUserReview = passedReview {
        cell.reviewTitle.text = currentUserReview.title!
      }
      cell.selectionStyle = .None
      return cell
    case 2:
      let cell = tableView.dequeueReusableCellWithIdentifier("reviewTextCell", forIndexPath: indexPath) as! ReviewTextCell
      if let currentUserReview = passedReview {
        cell.review.text = currentUserReview.review!
        cell.review.textColor = UIColor.blackColor()
      }
      cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
      cell.selectionStyle = .None
      return cell
    default: break
    }
    return UITableViewCell()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
}


extension AddMovieReviewVC: UITableViewDelegate {
  /*
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == 0 {
      let cell = cell as! StarRating
    //  cell.separatorInset.left = cell.rating.frame.origin.x - 10
    } else if indexPath.row == 1 {
      let cell = cell as! TitleCell
    //  cell.separatorInset.left = cell.reviewTitle.frame.origin.x - 10
    }
  }
  */
  
}







 