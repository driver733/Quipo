//
//  ProfileVC.swift
//  Reviews
//
//  Created by Admin on 29/06/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import OAuthSwift
import SwiftyJSON
import VK_ios_sdk
import InstagramKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import KeychainAccess
import FontBlaster
import TLYShyNavBar
import Parse
import SDWebImage







class ProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
   
  @IBOutlet weak var tableView: UITableView!
  
  var textArray: NSMutableArray! = NSMutableArray()
  var viewSelected = ""
  var loginActivityIndicator: UIActivityIndicatorView!
  let loginActivityIndicatorBackgroundView = UIView()
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      
      
      
        
            if indexPath.row == 0 {
              let cell = tableView.dequeueReusableCellWithIdentifier("ProfileTopCell", forIndexPath: indexPath) as! ProfileTopCell
              cell.awaitedView.layer.cornerRadius = 8
              cell.awaitedView.layer.masksToBounds = true
              cell.followersView.layer.cornerRadius = 8
              cell.followersView.layer.masksToBounds = true
              cell.followingView.layer.cornerRadius = 8
              cell.followingView.layer.masksToBounds = true
              cell.favouriteView.layer.cornerRadius = 8
              cell.favouriteView.layer.masksToBounds = true
              cell.watchedView.layer.cornerRadius = 8
              cell.watchedView.layer.masksToBounds = true
              cell.userReviewsView.layer.cornerRadius = 8
              cell.userReviewsView.layer.masksToBounds = true
              
              
             
              
              cell.profileImageView.sd_setImageWithURL(NSURL(string: (PFUser.currentUser())!["bigProfileImage"] as! String), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImageView.bounds.size), options: SDWebImageOptions.RefreshCached, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                if let image = image where error == nil {
                  cell.profileImageView.image = Toucan(image: image).maskWithEllipse().image
                }
              })
              
              

              cell.followingCount.text = String(UserSingelton.sharedInstance.following.count)
              cell.followersCount.text = String(UserSingelton.sharedInstance.followers.count)
              
              
              
              
              return cell
       }
              
       else {
              switch viewSelected {
        
              case "following":
                
                let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
              
                let user = (UserSingelton.sharedInstance.following)[indexPath.row - 1]
                
                cell.userName.text = user.username
                cell.followButton.addTarget(self, action: "didTapFollowButton:", forControlEvents: UIControlEvents.TouchUpInside)
                if user.isFollowed! {
                  cell.followButton.setTitle("following", forState: .Normal)
                  cell.followButton.setTitleColor(.greenColor(), forState: .Normal)
                }
                cell.profileImage.sd_setImageWithURL(
                  NSURL(string: user.profileImageURL!),
                  placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
                  options: SDWebImageOptions.RefreshCached,
                  completed:{
                    (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                    if image != nil {
                      cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
                    }
                  }
                )

                
                return cell
                
                
                
              case "followers":
                
                let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
                let user = (UserSingelton.sharedInstance.followers)[indexPath.row - 1]
                
                cell.userName.text = user.username
                cell.followButton.addTarget(self, action: "didTapFollowButton:", forControlEvents: UIControlEvents.TouchUpInside)
                if user.isFollowed == true {
                  cell.followButton.setTitle("following", forState: .Normal)
                  cell.followButton.setTitleColor(.greenColor(), forState: .Normal)
                }
                cell.profileImage.sd_setImageWithURL(
                  NSURL(string: user.profileImageURL!),
                  placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
                  options: SDWebImageOptions.RefreshCached,
                  completed:{
                    (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                    if image != nil {
                      cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
                    }
                  }
                )
                
                
                return cell

                
                
                
                
                
                
                

              default:
                return UITableViewCell()
       }

      }
      
    }
    
  func startLoginActivityIndicator() {
    loginActivityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 10, 10)) as UIActivityIndicatorView
    let loadingIndicatorBackgroundView =  UIView(frame: self.view.frame)
    loadingIndicatorBackgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    loadingIndicatorBackgroundView.center = self.view.center
    loadingIndicatorBackgroundView.layer.cornerRadius = 10
    loginActivityIndicator.center = self.view.center
    loginActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    self.view.addSubview(loadingIndicatorBackgroundView)
    self.view.addSubview(loginActivityIndicator)
    loginActivityIndicator.startAnimating()
  }
  
  func stopLoginActivityIndicator() {
    if loginActivityIndicator != nil {
      loginActivityIndicator.stopAnimating()
      loginActivityIndicator.removeFromSuperview()
    }
  }
  
    
    
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch viewSelected {
      
      case "userReviews":
      return 0
      
      case "following":
      return UserSingelton.sharedInstance.following.count + 1
      
      case "followers":
      return UserSingelton.sharedInstance.followers.count + 1
      
    default: break
    }
    
    
   
    return 1
  }
  
    
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
  /*
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.alpha = 0
        return view
    }
*/
    
    override func viewDidLoad() {
      super.viewDidLoad()

    
      tableView.registerNib(UINib(nibName: "ProfileTopCell", bundle: nil), forCellReuseIdentifier: "ProfileTopCell")
      tableView.registerNib(UINib(nibName: "ProfileUserReviews", bundle: nil), forCellReuseIdentifier: "ProfileUserReviews")   
      tableView.registerNib(UINib(nibName: "ProfileFollowerCell", bundle: nil), forCellReuseIdentifier: "ProfileFollowerCell")
      tableView.delegate = self
      tableView.dataSource = self
      tableView.rowHeight = UITableViewAutomaticDimension;
      tableView.estimatedRowHeight = 44.0;
 
      shyNavBarManager.scrollView = self.tableView
  
      
      self.navigationController?.navigationBar.barTintColor = UIColor.quipoColor()
    
      self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
      
      
      
      
      
          //      self.automaticallyAdjustsScrollViewInsets = false
        
        
        
        
         let gesture = UITapGestureRecognizer(target: self, action: "cellPressed:")
         self.view.addGestureRecognizer(gesture)
         gesture.cancelsTouchesInView = false
        
        
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: "settings:")
        
        viewSelected = "following"
       
        
    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profileSettings" {
           
        }
    }
    */
    
    func settings(sender: UIBarButtonItem) {
        performSegueWithIdentifier("profileSettings", sender: nil)
    }
    
    
    
    
    func cellPressed(press: UITapGestureRecognizer) {
        
        if press.state == .Ended {
            let location = press.locationInView(tableView)
            let path = tableView.indexPathForRowAtPoint(location)
            if path!.row == 0 {
                let newCell: ProfileTopCell = tableView.cellForRowAtIndexPath(path!) as! ProfileTopCell
              
                var viewPoint = newCell.awaitedView.convertPoint(location, fromView: tableView)
                if newCell.awaitedView.pointInside(viewPoint, withEvent: nil) {
                  
                    viewSelected = "reviews"
                    tableView.reloadData()
                    
                }
                
                viewPoint = newCell.favouriteView.convertPoint(location, fromView: tableView)
                if newCell.favouriteView.pointInside(viewPoint, withEvent: nil){
                    
                    viewSelected = ""
                    tableView.reloadData()
                }
                
                viewPoint = newCell.watchedView.convertPoint(location, fromView: tableView)
                if newCell.watchedView.pointInside(viewPoint, withEvent: nil){
                }
                
                viewPoint = newCell.followingView.convertPoint(location, fromView: tableView)
                if newCell.followingView.pointInside(viewPoint, withEvent: nil) {
                  viewSelected = "following"
                  tableView.reloadData()
                }
                
                viewPoint = newCell.followersView.convertPoint(location, fromView: tableView)
                if newCell.followersView.pointInside(viewPoint, withEvent: nil) {
                  viewSelected = "followers"
                  tableView.reloadData()
                }
                
                viewPoint = newCell.userReviewsView.convertPoint(location, fromView: tableView)
                if newCell.userReviewsView.pointInside(viewPoint, withEvent: nil){
                }
                
                
            }
            
            
        }

        
    }
    

    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    

    

    

}



extension UICollectionViewDataSource {
  
}






