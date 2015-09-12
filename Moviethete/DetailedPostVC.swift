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

class DetailedPostVC: UIViewController {

  @IBOutlet var tableView: UITableView!
  
  var passedPosterImage: UIImage? = nil
  var passedMovieInfo = Dictionary<String, String>()
  var passedPost: Post? = nil
  var passedColor = UIColor()
  var textColor = UIColor()
  var navBarShadowImage = UIImage()
  var navBarBackgroundImage = UIImage()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNib(UINib(nibName: "DetailedPostMainCell", bundle: nil), forCellReuseIdentifier: "detailedPostCell")
    tableView.registerNib(UINib(nibName: "UserReviewCell", bundle: nil), forCellReuseIdentifier: "userReviewCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    
    self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "addPost"), animated: true)
    
  
    self.navigationController?.navigationBar.shadowImage = (getImageWithColor(UIColor.lightGrayColor(), size: (CGSizeMake(0.35, 0.35))))
  }
  
  
  func addPost() {
    performSegueWithIdentifier("addPost", sender: nil)
  }
  
  
  override func viewWillAppear(animated: Bool) {
    self.navigationController?.navigationBar.tintColor = textColor
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : textColor]
    self.transitionCoordinator()?.animateAlongsideTransition({
      (context: UIViewControllerTransitionCoordinatorContext) -> Void in
      self.navigationController?.navigationBar.subviews[1].hidden = true
      self.navigationController?.navigationBar.barTintColor = self.passedColor
      },
      completion: nil)    
  }
  
  
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = (segue.destinationViewController as? UINavigationController)?.viewControllers[0] as? AddMovieReviewVC {
      vc.post = passedPost!
    }
  }
  
  
}


extension DetailedPostVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch indexPath.row {
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("detailedPostCell", forIndexPath: indexPath) as! DetailedPostCell
      cell.posterImage.sd_setImageWithURL(NSURL(string: (passedPost?.standardPosterImageURL)!),
        placeholderImage: getImageWithColor(UIColor.lightGrayColor(),size: cell.posterImage.bounds.size))
      cell.movieInfo.text = passedPost?.movieGenre
      cell.movieInfo.textColor = textColor
      
      return cell
      
    default:
      let cell = tableView.dequeueReusableCellWithIdentifier("userReviewCell", forIndexPath: indexPath) as! UserReviewCell
      cell.profileImage.image = getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.frame.size)
    //  cell.profileImage.sd_setImageWithURL(NSURL(string: (passedPost?.profileImageURL)!), placeholderImage: getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.frame.size))
      return cell
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
}

















