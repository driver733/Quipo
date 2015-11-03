//
//  DetailedSettingsVC.swift
//  Moviethete
//
//  Created by Mike on 9/7/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import UIKit
import TwitterKit
import OAuthSwift
import SwiftyJSON
import VK_ios_sdk
import InstagramKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import KeychainAccess
import SwiftValidator
//import FontBlaster
import Parse
import ParseFacebookUtilsV4
import SDWebImage

class DetailedSettingsVC: UIViewController {
   
  

  @IBOutlet var tableView: UITableView!
  
  var cellIndexPath = NSIndexPath()
  
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      
      tableView.registerNib(UINib(nibName: "ProfileFollowerCell", bundle: nil), forCellReuseIdentifier: "ProfileFollowerCell")
      tableView.registerNib(UINib(nibName: "ProfileSettingsFollowFriendsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsFollowFriendsCell")
      tableView.delegate = self
      tableView.dataSource = self
      
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 44.0
    }
  
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
  
  
  
  override func viewWillDisappear(animated: Bool) {
   
      // second if => "self" is being shown because of a "back" button.
    if UserSingelton.sharedInstance.shouldUpdateLinkedAccounts {
      UserSingelton.sharedInstance.updateUserSubscriptions(
        UserSingelton.sharedInstance.followedUsers,
        unfollowedUsersObjectIDs: UserSingelton.sharedInstance.unfollowedUsers
        )
        .continueWithBlock({ (task: BFTask!) -> AnyObject! in
          UserSingelton.sharedInstance.shouldUpdateLinkedAccounts = false
          return nil
        })
    }
    
  }
  
  
  func checkButtonTapped(sender: UIButton) -> NSIndexPath {
    let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
    let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
    if indexPath != nil {
      return indexPath!
    }
    return NSIndexPath()
  }
  
  
  func didTapFollowButton(sender: UIButton) {
    
      let indexPath = checkButtonTapped(sender)
      let user = UserSingelton.sharedInstance.allFriends[cellIndexPath.row][indexPath.row].pfUser!
      let cell = tableView.cellForRowAtIndexPath(indexPath) as! ProfileFollowerCell
    if sender.titleLabel?.text == "+ follow" {
      UserSingelton.sharedInstance.followedUsers.append(user.objectId!)
      cell.followButton.setTitle("following", forState: .Normal)
      cell.followButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
    } else {
      let user = UserSingelton.sharedInstance.allFriends[cellIndexPath.row][indexPath.row].pfUser!
      UserSingelton.sharedInstance.unfollowedUsers.append(user.objectId!)
      cell.followButton.setTitle("+ follow", forState: .Normal)
      cell.followButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
    }
    UserSingelton.sharedInstance.shouldUpdateLinkedAccounts = true
  }

  
  
  }

  
  



// MARK: - UITableViewDataSource
extension DetailedSettingsVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
    let user = UserSingelton.sharedInstance.allFriends[cellIndexPath.row][indexPath.row]
    
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
    
  }
  
  
  
  
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return UserSingelton.sharedInstance.allFriends[cellIndexPath.row].count
  }
  
  
  
}





// MARK: - UITableViewDelegate
extension DetailedSettingsVC: UITableViewDelegate {
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    switch indexPath.row {
        default: break
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if cell.isKindOfClass(ProfileFollowerCell) {
      let cell = cell as! ProfileFollowerCell
      cell.separatorInset.left = cell.userName.frame.origin.x
    }
  }
  
}




