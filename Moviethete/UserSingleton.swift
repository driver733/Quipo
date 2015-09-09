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
import Bolts

public struct UserSingelton {
  
  static var sharedInstance = UserSingelton()
  
  var allFriends = [[User]]()
  var followFriendsData = [FollowFriends]()
  
  var facebookFriends = [User]()
  var vkontakteFriends = [User]()

  

  
  init() {}
  

  mutating func loadFollowFriendsData() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    
  //  UserSingelton.sharedInstance.followFriendsData.removeAll(keepCapacity: false)      // I dont understand why clearing these array does not work her :(
    UserSingelton.sharedInstance.allFriends.removeAll(keepCapacity: false)
    
//    UserSingelton.sharedInstance.vkontakteFriends.removeAll(keepCapacity: false)
//    UserSingelton.sharedInstance.facebookFriends.removeAll(keepCapacity: false)

    let tasks = BFTask(forCompletionOfAllTasks: [loadVkontakteFriends(), loadFacebookFriends()])
    tasks.continueWithBlock { (task: BFTask!) -> AnyObject! in
      UserSingelton.sharedInstance.followFriendsData.removeAll(keepCapacity: false)
      
      self.loadFollowFriendsCells().continueWithBlock({ (task: BFTask!) -> AnyObject! in
        mainTask.setResult(nil)
        return nil
     })
      return nil
    }
    
    
    
    return mainTask.task
    
  }
  
  
  
  
  
  
  mutating func loadVkontakteFriends() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    
    if VKSdk.wakeUpSession() {
  
      let vkReq = VKApi.requestWithMethod("friends.getAppUsers", andParameters: nil, andHttpMethod: "GET")
        
      self.getVKUserID().continueWithBlock({ (task: BFTask!) -> AnyObject! in
        if task.error == nil  {
          let vkUserID = task.result as! String
          vkReq.executeWithResultBlock({ (response: VKResponse!) -> Void in
            let json = JSON(response.json)
            var vkList = [String]()
            for (index, _) in json.enumerate() {
              vkList.append(String(json[index]))
            }
            let query = PFUser.query()
            query?.whereKey("VKID", containedIn: vkList)
            query?.whereKey("VKID", notEqualTo: vkUserID)
            query?.findObjectsInBackgroundWithBlock({ (results: [AnyObject]?, error: NSError?) -> Void in
              if error == nil {
                let foundUsers = results as! [PFUser]
                UserSingelton.sharedInstance.vkontakteFriends.removeAll(keepCapacity: false)
                for user in foundUsers {
                  let follower = User(theUsername: user.username!, theProfileImageURL: user["smallProfileImage"] as! String)
                  UserSingelton.sharedInstance.vkontakteFriends.append(follower)
                }
                if UserSingelton.sharedInstance.vkontakteFriends.count > 0 {
                  UserSingelton.sharedInstance.allFriends.append(UserSingelton.sharedInstance.vkontakteFriends)
                }
                mainTask.setResult(nil)
              }
            })
              }, errorBlock: { (error: NSError!) -> Void in
            })
          }
          return nil
        })
        
        
          
      
     
      
    } else {
      mainTask.setResult(nil)
    }
     return mainTask.task
  }
  
  
  
  
  
  private func getVKUserID() -> BFTask {
    let task = BFTaskCompletionSource()
    let vkReq = VKApi.users().get()
    vkReq.executeWithResultBlock({ (response: VKResponse!) -> Void in
    let json = JSON(response.json)
    if let userID = json[0]["id"].number {
      task.setResult(String(userID))
    }
      
      }) { (error: NSError!) -> Void in
        
    }
    
    return task.task
    
  }
  
  
  
  
  
  
  mutating func loadFollowFriendsCells() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    
    if FBSDKAccessToken.currentAccessToken() != nil {
      if UserSingelton.sharedInstance.facebookFriends.count != 0 {
        let fbFriends = FollowFriends(
          theLocalIconName: "facebook",
          theNumberOfFriends: UserSingelton.sharedInstance.facebookFriends.count,
          theServiceName: "facebook"
          )
          UserSingelton.sharedInstance.followFriendsData.append(fbFriends)
      }
    }
    
    
    if VKSdk.isLoggedIn() {
      if UserSingelton.sharedInstance.vkontakteFriends.count != 0 {
        let vkFriends = FollowFriends(
          theLocalIconName: "vk",
          theNumberOfFriends: UserSingelton.sharedInstance.vkontakteFriends.count,
          theServiceName: "Vkontakte"
        )
        UserSingelton.sharedInstance.followFriendsData.append(vkFriends)
      }
    }
    
    mainTask.setResult(nil)
    
    return mainTask.task
    
  }
  
  
  
  
  
  
  
  mutating func loadFacebookFriends() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    
    if FBSDKAccessToken.currentAccessToken() != nil && FBSDKProfile.currentProfile() != nil {
  
  
   let graphRequest: FBSDKGraphRequest =  FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields" : "friends"], HTTPMethod: "GET")
     
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
            UserSingelton.sharedInstance.facebookFriends.removeAll(keepCapacity: false)
            for user in foundUsers {
              let follower = User(theUsername: user.username!, theProfileImageURL: user["smallProfileImage"] as! String)
              UserSingelton.sharedInstance.facebookFriends.append(follower)
            }
            
            if UserSingelton.sharedInstance.facebookFriends.count > 0 {
               UserSingelton.sharedInstance.allFriends.append(UserSingelton.sharedInstance.facebookFriends)
            }
            mainTask.setResult(nil)
          })
            
          }
        else {
         print(error.localizedDescription)
        }
      })
      
    } else {
      mainTask.setResult(nil)
    }
    
    return mainTask.task
 
  }

  
  
  
  
  
}





