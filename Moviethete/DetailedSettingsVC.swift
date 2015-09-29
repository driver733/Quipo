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
import FontBlaster
import Parse
import ParseFacebookUtilsV4
import SDWebImage

class DetailedSettingsVC: UIViewController {
  
  
  
  
  func checkButtonTapped(sender: UIButton) -> NSIndexPath {
    let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
    let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
    if indexPath != nil {
      return indexPath!
    }
    return NSIndexPath()
  }
  

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
  
  
  func didTapFollowButton(sender: UIButton) {
    let indexPath = checkButtonTapped(sender)
    let user = UserSingelton.sharedInstance.allFriends[cellIndexPath.row][indexPath.row].pfUser!
    UserSingelton.sharedInstance.followUser(user)
  }

  
  
  
  
  }

  
  



// MARK: - UITableViewDataSource
extension DetailedSettingsVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
      let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
      let user = UserSingelton.sharedInstance.allFriends[cellIndexPath.row][indexPath.row]
      
      cell.userName.text = user.username
      cell.followButton.addTarget(self, action: "didTapFollowButton:", forControlEvents: UIControlEvents.TouchUpInside)
      cell.profileImage.sd_setImageWithURL(
        NSURL(string: user.profileImageURL!),
        placeholderImage: getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.bounds.size),
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




