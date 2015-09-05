//
//  AddMovieReviewVC.swift
//  Moviethete
//
//  Created by Mike on 9/3/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import UIKit
import Bolts
import HCSStarRatingView

class AddMovieReviewVC: UIViewController {
  
  var post = Post()

  @IBOutlet var tableView: UITableView!
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      
      tableView.registerNib(UINib(nibName: "StarRating", bundle: nil), forCellReuseIdentifier: "StarRating")
      tableView.registerNib(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
      tableView.registerNib(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 44.0
      

      self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "dismiss"), animated: true)
      self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Done, target: self, action: Selector("postMovieReview")), animated: true)
    }
  
  
  
  func postMovieReview() {
    
    let starRatingCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! StarRating
    let reviewTitleCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TitleCell
    let reviewCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! ReviewCell
    
    
    UserReview.sharedInstance.uploadReview(post, rating: Int(starRatingCell.rating.value), reviewTitle: reviewTitleCell.reviewTitle.text!, review: reviewCell.review.text).continueWithBlock { (task: BFTask!) -> AnyObject! in
      self.dismissViewControllerAnimated(true, completion: nil)
      return nil
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
      let cell = tableView.dequeueReusableCellWithIdentifier("StarRating", forIndexPath: indexPath)
      return cell
    case 1:
      let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath)
      return cell
    case 2:
      let cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell", forIndexPath: indexPath)
      cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
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







 