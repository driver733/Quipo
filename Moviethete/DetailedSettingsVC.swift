//
//  DetailedSettingsVC.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 9/7/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
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
  
  var shouldUpdateLinkedAccounts = false
  
  var tableView = UITableView()
  var cellIndexPath: NSIndexPath!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view = tableView
    
//    loadingStateDelegate = self.navigationController?.viewControllers.first as! ProfileSettings // ProfileSettingsVC
    
    tableView.registerNib(UINib(nibName: "ProfileFollowerCell", bundle: nil), forCellReuseIdentifier: "ProfileFollowerCell")
    tableView.registerNib(UINib(nibName: "ProfileSettingsFollowFriendsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsFollowFriendsCell")
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    tableView.tableFooterView = UIView(frame: CGRectZero)
  }
  
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(animated: Bool) {
    if shouldUpdateLinkedAccounts {
      CurrentUser.sharedCurrentUser().updateUserSubscriptions(
                                  CurrentUser.sharedCurrentUser().followedUsers,
        unfollowedUsersObjectIDs: CurrentUser.sharedCurrentUser().unfollowedUsers
        )
        .continueWithBlock({ (task: BFTask!) -> AnyObject! in
          self.shouldUpdateLinkedAccounts = false
          return nil
        })
    }
  }
  
  func checkButtonTapped(sender: UIButton) -> NSIndexPath {
    let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
    let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
    if let indexPath = indexPath {
      return indexPath
    }
    return NSIndexPath()
  }
  
  func didTapFollowButton(sender: UIButton) {
    let indexPath = checkButtonTapped(sender)
    let user = CurrentUser.sharedCurrentUser().allFriends[cellIndexPath.row][indexPath.row].pfUser!
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! ProfileFollowerCell
    if sender.titleLabel?.text == "+ follow" {
      CurrentUser.sharedCurrentUser().followedUsers.append(user.objectId!)
      cell.followButton.setTitle("following", forState: .Normal)
      cell.followButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
    } else {
      let user = CurrentUser.sharedCurrentUser().allFriends[cellIndexPath.row][indexPath.row].pfUser!
      CurrentUser.sharedCurrentUser().unfollowedUsers.append(user.objectId!)
      cell.followButton.setTitle("+ follow", forState: .Normal)
      cell.followButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
    }
    shouldUpdateLinkedAccounts = true
  }

  
  
  }

// MARK: - UITableViewDataSource
extension DetailedSettingsVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
    let user = CurrentUser.sharedCurrentUser().allFriends[cellIndexPath.row][indexPath.row]
    cell.userName.text = user.username
    cell.followButton.addTarget(self, action: "didTapFollowButton:", forControlEvents: UIControlEvents.TouchUpInside)
    if user.isFollowed {
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
      return CurrentUser.sharedCurrentUser().allFriends[cellIndexPath.row].count
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




