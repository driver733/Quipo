//
//  FollowFriends.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 9/8/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
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
//import FontBlaster
import Parse
import ParseFacebookUtilsV4

class FollowFriends {
  var localIconName: String?
  var numberOfFriends: Int?
  var serviceName: String?
  var description: String?
  
  private init() {}

  init(theLocalIconName: String, theServiceName: String, theNumberOfFriends: Int) {
    localIconName = theLocalIconName
    numberOfFriends = theNumberOfFriends
    serviceName = theServiceName
    description = String(theNumberOfFriends) + " " + theServiceName + " " + (theNumberOfFriends == 1 ? "friend" : "friends")
  }
  
}


class LinkedAccount {
  
  private enum LinkedAccountType: Int {
    case Facebook = 0
    case Instagram
    case Vkontakte
  }
  
  var username: String!
  var serviceName: String!
  var localIconName: String!
  var loginTask: (() -> BFTask)!
  var logout: (() -> ())!
  var isLoggedIn = false
  private(set) static var linkedAccounts: [LinkedAccount] = {
     return LinkedAccount.setupLinkedAccounts()
  }()

  init(theLocalIconName: String, theServiceName: String, theUsername: String, theLoginTask: (() -> BFTask), thelogout: (() -> ()), theIsLoggedIn: Bool) {
    localIconName = theLocalIconName
    serviceName = theServiceName
    username = theUsername
    loginTask = theLoginTask
    logout = thelogout
    isLoggedIn = theIsLoggedIn
  }
  
  // ======================================================= //
  // MARK: - LinkedAccounts` initialization
  // ======================================================= //
  
  class func facebookLA() -> LinkedAccount {
    return LinkedAccount(
      theLocalIconName: "facebook",
      theServiceName:   "Facebook",
      theUsername:      "",
      theLoginTask:     UserSingleton.getSharedInstance().loginWithFacebook,
      thelogout:    UserSingleton.getSharedInstance().logoutFromFacebook,
      theIsLoggedIn:    FBSDKAccessToken.currentAccessToken() != nil ? true : false
    )
  }
  
  class func instagramLA() -> LinkedAccount {
   return LinkedAccount(
      theLocalIconName: "instagram",
      theServiceName:   "Instagram",
      theUsername:      "",
      theLoginTask:     UserSingleton.getSharedInstance().loginWithInstagram,
      thelogout:    UserSingleton.getSharedInstance().logoutFromInstagram,
      theIsLoggedIn:    (UserSingleton.getSharedInstance().linkedAccountsKeychain["instagram"] != nil) ? true : false
    )
  }
  
  class func vkontakteLA() -> LinkedAccount {
    return LinkedAccount(
      theLocalIconName: "vk",
      theServiceName:   "VKontakte",
      theUsername:      "",
      theLoginTask:     UserSingleton.getSharedInstance().loginWithVkontakte,
      thelogout:    UserSingleton.getSharedInstance().logoutFromVkontakte,
      theIsLoggedIn:    VKSdk.isLoggedIn()
    )
  }
  
  class func setupLinkedAccounts() -> [LinkedAccount] {
    return [facebookLA(), instagramLA(), vkontakteLA()]
  }
  
  // ======================================================= //
  // MARK: - Update
  // ======================================================= //
  
 class func updateInstagram() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let instagram = linkedAccounts[LinkedAccountType.Instagram.rawValue]
    let linkedAccountsKeychain = UserSingleton.getSharedInstance().linkedAccountsKeychain
    if linkedAccountsKeychain["instagram"] != nil {
      UserSingleton.getSharedInstance().instagramGetSelfUserDetailsWithSuccess().continueWithSuccessBlock { (task: BFTask) -> AnyObject? in
        let currentUser = task.result as! InstagramUser     
        instagram.username = currentUser.username
        instagram.isLoggedIn = true
        mainTask.setResult(nil)
        return nil
      }
    } else {
      instagram.username = ""
      instagram.isLoggedIn = false
      mainTask.setResult(nil)
    }
    return mainTask.task
  }
  
 class func updateVkontakte() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let vk = linkedAccounts[LinkedAccountType.Vkontakte.rawValue]
    if VKSdk.isLoggedIn() {
      UserSingleton.getSharedInstance().getVKUsername().continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
        vk.username = (task.result as! String)
        vk.isLoggedIn = true
        mainTask.setResult(nil)
        return nil
      })
    } else {
      vk.username = ""
      vk.isLoggedIn = false
      mainTask.setResult(nil)
    }
    return mainTask.task
  }
  

 class func updateAll() -> BFTask {
    let tasks = [
      updateInstagram(),
      updateVkontakte()
    ]
    return BFTask(forCompletionOfAllTasksWithResults: tasks)
  }
  
  
  }







