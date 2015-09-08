//
//  UserSingleton.swift
//  Moviethete
//
//  Created by Mike on 9/6/15.
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

public struct UserSingelton {
  
  static var sharedInstance = UserSingelton()
  
  var facebookFriends = [User]()
  
  
  
  
  init() {}
  
  
  
  
  
  
  
  
  
  
  
  
  mutating func loadFacebookFriends(completionHandler: () -> Void) {
    if FBSDKAccessToken.currentAccessToken() != nil {
      let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields" : "email"])
      
      graphRequest.startWithCompletionHandler({
        (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
        if error == nil {
          let json = JSON(result)
          var fbList = [String]()
          for (_, subJson) in json["data"] {
            print(subJson["id"].stringValue)
            fbList.append(subJson["id"].stringValue)
          }
          
          
          let query = PFUser.query()
          query?.whereKey("FBID", containedIn: fbList)
          query?.whereKey("FBID", notEqualTo: FBSDKProfile.currentProfile().userID)
          query?.findObjectsInBackgroundWithBlock({ (results: [AnyObject]?, error: NSError?) -> Void in
            let foundUsers = results as! [PFUser]
            UserSingelton.sharedInstance.facebookFriends.removeAll(keepCapacity: true)
            for user in foundUsers {
              let follower = User(theUsername: user.username!, theProfileImageURL: user["smallProfileImage"] as! String)
              UserSingelton.sharedInstance.facebookFriends.append(follower)
            }
            
            completionHandler()
            
          })
   
          
        
        }
        else {
          // process error
        }
      })
      
    }
 
  }

  
  
  
  
  
}