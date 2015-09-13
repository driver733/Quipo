//
//  FollowFriends.swift
//  Moviethete
//
//  Created by Mike on 9/8/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import Foundation
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



struct FollowFriends {
  
  static var sharedInstance = FollowFriends()
  
  var linkedAccounts = [FollowFriends]()
  
  var localIconName: String?
  var numberOfFriends: Int?
  var serviceName: String?
  var description: String?
  var username: String?
  
  init() {}
  
  init(theLocalIconName: String, theNumberOfFriends: Int, theServiceName: String) {
    localIconName = theLocalIconName
    numberOfFriends = theNumberOfFriends
    serviceName = theServiceName
    description = String(theNumberOfFriends) + " " + theServiceName + " " + (theNumberOfFriends == 1 ? "friend" : "friends")
  }
  
  init(theLocalIconName: String, theServiceName: String, theUsername: String) {
    localIconName = theLocalIconName
    serviceName = theServiceName
    username = theUsername
  }
  
  
  
  
  mutating func loadLinkedAccountsData() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    
    FollowFriends.sharedInstance.linkedAccounts.removeAll(keepCapacity: false)
    
    var fb = FollowFriends(theLocalIconName: "facebook", theServiceName: "Facebook", theUsername: "")
    if FBSDKAccessToken.currentAccessToken() != nil && FBSDKProfile.currentProfile() != nil {
      fb.username = FBSDKProfile.currentProfile().name
    }
    FollowFriends.sharedInstance.linkedAccounts.append(fb)
      
    var vk = FollowFriends(theLocalIconName: "vk", theServiceName: "Vkontakte", theUsername: "")
    if VKSdk.isLoggedIn() {
      UserSingelton.sharedInstance.getVKUsername().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
         vk.username = task.result as? String
        FollowFriends.sharedInstance.linkedAccounts.append(vk)
        return nil
      })
    } else {
      FollowFriends.sharedInstance.linkedAccounts.append(vk)
    }
    
      
    var instagram = FollowFriends(theLocalIconName: "instagram", theServiceName: "Instagram", theUsername: "")
    let instmEngine = InstagramEngine.sharedEngine()
    let instagramKeychain = UserSingelton.sharedInstance.instagramKeychain
    if instagramKeychain["instagram"] != nil {
      instmEngine.accessToken = instagramKeychain["instagram"]
      instmEngine.getSelfUserDetailsWithSuccess({ (currentUser: InstagramUser!) -> Void in
      instagram.username = currentUser.username
      FollowFriends.sharedInstance.linkedAccounts.append(instagram)
        mainTask.setResult(nil)
        }, failure: { (error: NSError!, errorCode: Int) -> Void in
          mainTask.setResult(nil)
      })
    } else {
      FollowFriends.sharedInstance.linkedAccounts.append(instagram)
      }
    
    

    return mainTask.task
  }
  
  
  
  
  
  
}