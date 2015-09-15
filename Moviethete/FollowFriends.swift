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
  
  
  
  
  func loadLinkedAccountsData() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    
    FollowFriends.sharedInstance.linkedAccounts.removeAll(keepCapacity: false)
    
    var fb = FollowFriends(theLocalIconName: "facebook", theServiceName: "Facebook", theUsername: "")
    
    if FBSDKAccessToken.currentAccessToken() != nil && FBSDKProfile.currentProfile() != nil {
      fb.username = FBSDKProfile.currentProfile().name
    }
    FollowFriends.sharedInstance.linkedAccounts.append(fb)
    
    UserSingelton.sharedInstance.instagramgetSelfUserDetailsWithSuccess().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      
      let subTask = BFTaskCompletionSource()
      
      var instagram = FollowFriends(theLocalIconName: "instagram", theServiceName: "Instagram", theUsername: "")
      
      let instagramKeychain = UserSingelton.sharedInstance.instagramKeychain
      if instagramKeychain["instagram"] != nil {
        let currentUser = task.result as! InstagramUser
        instagram.username = currentUser.username
        FollowFriends.sharedInstance.linkedAccounts.insert(instagram, atIndex: 1)
        } else {
        FollowFriends.sharedInstance.linkedAccounts.insert(instagram, atIndex: 1)
      }
      
      subTask.setResult(nil)
      
      return UserSingelton.sharedInstance.getVKUsername()
      }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      
        var vk = FollowFriends(theLocalIconName: "vk", theServiceName: "Vkontakte", theUsername: "")
        
        if VKSdk.isLoggedIn() {
          vk.username = task.result as? String
          FollowFriends.sharedInstance.linkedAccounts.append(vk)
        } else {
          FollowFriends.sharedInstance.linkedAccounts.append(vk)
        }
        
        mainTask.setResult(nil)
        
        return nil
    }
    
    return mainTask.task
  }
  
  
  
  
  
  

  
}