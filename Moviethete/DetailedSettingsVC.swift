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

  @IBOutlet var tableView: UITableView!
  
  var cellIndexPath = NSIndexPath()
  
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      tableView.registerNib(UINib(nibName: "ProfileSettingsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsCell")
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

  
  
}


// MARK: - UITableViewDataSource
extension DetailedSettingsVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    switch cellIndexPath.section {
      
      
      
      
    case 0:   // follow friends
    
      let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
      let user = UserSingelton.sharedInstance.allFriends[cellIndexPath.row][indexPath.row]
      
      cell.userName.text = user.username
      cell.profileImage.sd_setImageWithURL(
        NSURL(string: user.profileImageURL!),
        placeholderImage: getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.bounds.size),
        options: SDWebImageOptions.RefreshCached,
        completed:{
          (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
          cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
        }
      )
      
      return cell
      
      
      
      
    case 1:
      return UITableViewCell()
      
      
      
    case 2: // Settings
      
      switch cellIndexPath.row {
      case 0:  // Linked accounts
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsFollowFriendsCell", forIndexPath: indexPath) as! ProfileSettingsFollowFriendsCell
        let linkedAccount = FollowFriends.sharedInstance.linkedAccounts[indexPath.row]
        cell.icon.image = UIImage(named: linkedAccount.localIconName!)
        cell.label.text = linkedAccount.serviceName
        cell.account.text = linkedAccount.username
        
        return cell
        
        
      default: break
      }
    
      
      
      
      
      
      
      
      
      
      
      
      
      
      
    default: break
    
  }
    
    
    
    return UITableViewCell()
  
  }
  
  
  
  
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch cellIndexPath.section {
      
    case 0:
      return UserSingelton.sharedInstance.allFriends[cellIndexPath.row].count
      
    case 2:
      return FollowFriends.sharedInstance.linkedAccounts.count
      
      
      
      
    default: break
    }

    return 1
    
  }
  
  
  
}





// MARK: - UITableViewDelegate
extension DetailedSettingsVC: UITableViewDelegate {
  
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.row {
    case 0:
      if FBSDKAccessToken.currentAccessToken() == nil {
        UserSingelton.sharedInstance.loginWithFacebook()
        
      }
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


