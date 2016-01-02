//
//  User.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 9/6/15.
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

class User {
  
  var username: String!
  var profileImageURL: String!
  var pfUser: PFUser!
  var isFollowed = false
//  var isFollowedBy = false
  
  var followers = [User]()
  var following = [User]()
  
  var watchedPosts = [Post]()
  var favoritePosts = [Post]()
  var feedPosts = [Post]()
  var userPosts = [Post]()
  
  init(thePfUser: PFUser) {
    username = thePfUser.username!
    profileImageURL = thePfUser["smallProfileImage"] as? String
    pfUser = thePfUser
  }
  
  // ======================================================= //
  // MARK: - Posts
  // ======================================================= //
  
  func loadFeedPosts() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    Post.sharedInstance.loadPosts(pfUser, reqType: postsType.feed).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      self.feedPosts = task.result! as! [Post]
      mainTask.setResult(nil)
      return nil
    }
    return mainTask.task
  }
  
  func loadUserPosts() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    Post.sharedInstance.loadPosts(pfUser, reqType: postsType.user).continueWithBlock { (task: BFTask!) -> AnyObject! in
      self.userPosts = task.result! as! [Post]
      mainTask.setResult(nil)
      return nil
    }
    return mainTask.task
  }
  
  func loadWatchedPosts() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    Post.sharedInstance.loadPosts(pfUser, reqType: postsType.watched).continueWithBlock { (task: BFTask!) -> AnyObject! in
      self.watchedPosts = task.result! as! [Post]
      mainTask.setResult(nil)
      return nil
    }
    return mainTask.task
  }
  
  // ======================================================= //
  // MARK: - Followers
  // ======================================================= //
  
  func loadFollowers() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let query = PFQuery(className: "Follow")
    query.includeKey("from")
    query.whereKey("to", equalTo: pfUser)
    query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
      if let results = results {
        self.followers.removeAll(keepCapacity: false)
        for follow in results {
          let followerObj = follow["from"] as! PFUser
          let follower = User(thePfUser: followerObj)
          self.followers.append(follower)
        }
        mainTask.setResult(nil)
      }
    }
    return mainTask.task
  }
  
  func loadFollowingUsers() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let query = PFQuery(className: "Follow")
    query.includeKey("to")
    query.whereKey("from", equalTo: pfUser)
    query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
      if let results = results {
        self.following.removeAll(keepCapacity: false)
        for follow in results {
          let followerObj = follow["to"] as! PFUser
          self.following.append(User(thePfUser: followerObj))
        }
        mainTask.setResult(nil)
      }
    }
    return mainTask.task
  }
  
  func checkIfFollowersAreFollowed() {
    var followersPfUserObjectIDs = [String]()
    for follower in followers {
      followersPfUserObjectIDs.append(follower.pfUser.objectId!)
    }
    
    var followingPfUserObjectIDs = [String]()
    for follower in following {
      followingPfUserObjectIDs.append(follower.pfUser.objectId!)
    }
    
    for follower in followers {
      for followingObjID in followingPfUserObjectIDs {
        if followersPfUserObjectIDs.contains(followingObjID) {
          follower.isFollowed = true
        }
      }
    }
    
  }
  
  
//  func checkIfFollowedUsersFollowBack() {
//    var followersPfUserObjectIDs = [String]()
//    for follow in following {
//      followersPfUserObjectIDs.append(follow.pfUser.objectId!)
//    }
//    for follower in self.followers {
//      if followersPfUserObjectIDs.contains((follower.pfUser?.objectId)!) {
//        follower.isFollowedBy = true
//      } else {
//        follower.isFollowedBy = false
//      }
//    }
//  }

  // ======================================================= //
  // MARK: - Profile
  // ======================================================= //
  
  
  func updateAllProfileData() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    return BFTask(
      forCompletionOfAllTasks: [
        loadFollowingUsers(),
        loadFollowers(),
        loadUserPosts(),
        loadWatchedPosts()
      ]
      ).continueWithBlock { (task: BFTask!) -> AnyObject! in
   //    self.checkIfFollowersAreFollowed()
        
        
   //     self.checkIfFollowedUsersFollowBack()
        mainTask.setResult(nil)
        return nil
    }
  }
  
  
  
  
  
  
  
  
  

}


