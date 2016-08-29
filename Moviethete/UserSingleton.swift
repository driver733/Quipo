//
//  CurrentUser.swift
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
import Bolts
import KeychainAccess

protocol LoadingStateDelegate {
  func didStartNetworingActivity()
  func didEndNetworingActivity()
}

protocol FollowFriendsDelegate {
  func didUpdateFollowFriendsData()
}

class CurrentUser: User {
  
  private static var sharedInstance: CurrentUser!
  
  var loginLoadingStateDelegate: LoadingStateDelegate?
  var followFriendsDelegate: FollowFriendsDelegate?
  
  override private init(thePfUser: PFUser) {
    super.init(thePfUser: thePfUser)
  }
  
  class func sharedCurrentUser() -> CurrentUser {
    if sharedInstance == nil {
      if let currentUser = PFUser.currentUser() {
        sharedInstance = CurrentUser(thePfUser: currentUser)
      } else {
        let tempPFUser = PFUser()
        tempPFUser.username = ""
        tempPFUser["smallProfileImage"] = ""
        sharedInstance = CurrentUser(thePfUser: tempPFUser)
      }
    }
    return sharedInstance
  }
  
  //private
  class func resetSharedInstance() {
    sharedInstance = nil
  }
  
  /// All users linked through social networks (in other words, friends in linked social networks). Users are split into arrays each represeinting a linked social network, such as [Facebook], [Instagram], etc.
  var allFriends: [[User]] {
    var friends = [[User]]()
    if self.facebookFriends.count > 0 {
      friends.append(self.facebookFriends)
    }
    if self.instagramFriends.count > 0 {
      friends.append(instagramFriends)
    }
    if vkontakteFriends.count > 0 {
      friends.append(vkontakteFriends)
    }
    return friends
  }
  var followFriendsData = [FollowFriends]()
  var linkedAccountsKeychain = Keychain()
  var facebookFriends = [User]()
  var vkontakteFriends = [User]()
  var instagramFriends = [User]()
  
  var followedUsers = [String]()
  var unfollowedUsers = [String]()
  
// ======================================================= //
// MARK: - Parse
// ======================================================= //

  func checkUserLinkedAccounts() {
    checkIfFacebookAccessTokenIsPresent()
    checkIfInstagramAccessTokenIsPresent()
    checkIfVkontakteAccessTokenIsPresent()
  }
  
  func checkIfFacebookAccessTokenIsPresent() {
    if let facebookAccessToken = PFUser.currentUser()?["FBAccessToken"] as? String, fbUserID = PFUser.currentUser()?["FBID"] as? String {
      let fbAccessToken = FBSDKAccessToken(
        tokenString: facebookAccessToken,
        permissions: ["email", "public_profile", "user_friends"],
        declinedPermissions: nil,
        appID: "122664868071644",
        userID: fbUserID,
        expirationDate: nil,
        refreshDate: nil
      )
      FBSDKAccessToken.setCurrentAccessToken(fbAccessToken)
    }
  }

  func checkIfInstagramAccessTokenIsPresent() {
    if linkedAccountsKeychain["instagram"] == nil {
      if let instagramAccessToken = PFUser.currentUser()?["INSTMAccessToken"] as? String {
        self.linkedAccountsKeychain["instagram"] = instagramAccessToken
        let engine = InstagramEngine.sharedEngine()
        engine.accessToken = instagramAccessToken
      }
    }
  }
  
  func checkIfVkontakteAccessTokenIsPresent() {
    if let token = PFUser.currentUser()?["VKAccessToken"] as? String, vkUserID = PFUser.currentUser()?["VKID"] as? String  {
      let vkAccessToken = VKAccessToken(token: token, secret: "PuLAVPrHRvxkl24PWKDm", userId: vkUserID)
      vkAccessToken.saveTokenToDefaults("VKAccessToken")
//      VKSdk.setAccessToken(vkAccessToken)
    }
  }
  
  func updateUserSubscriptions(followedUsersObjectIDs: [String], unfollowedUsersObjectIDs: [String]) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    if followedUsersObjectIDs.count != 0 || unfollowedUsersObjectIDs.count != 0 {
      PFCloud.callFunctionInBackground("updateUserSubscriptions", withParameters:
        ["currentUserObjectId" :      (PFUser.currentUser()?.objectId)!,
         "followedUsersObjectIDs" :   self.followedUsers,
         "unFollowedUsersObjectIDs" : self.unfollowedUsers]
        ).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            return self.updateAllProfileData()
        }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            self.followedUsers.removeAll(keepCapacity: false)
            self.unfollowedUsers.removeAll(keepCapacity: false)
            mainTask.setResult(nil)
            return nil
      }
    } else {
      mainTask.setResult(nil)
    }
    return mainTask.task
  }
  
  override func loadFollowingUsers() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let query = PFQuery(className: "Follow")
    query.includeKey("to")
    query.whereKey("from", equalTo: PFUser.currentUser()!)
    query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
      if let results = results {
        self.following.removeAll(keepCapacity: false)
        for follow in results {
          let followerObj = follow["to"] as! PFUser
          let follower = User(thePfUser: followerObj)
          follower.isFollowed = true
          self.following.append(follower)
        }
  //      self.checkIfFollowedUsersFollowBack()
        mainTask.setResult(nil)
      }
    }
    return mainTask.task
  }
  
  override func loadFollowers() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let query = PFQuery(className: "Follow")
    query.includeKey("from")
    query.whereKey("to", equalTo: PFUser.currentUser()!)
    query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
      if let results = results {
        self.followers.removeAll(keepCapacity: false)
        for follow in results {
          let followerObj = follow["from"] as! PFUser
          let follower = User(thePfUser: followerObj)
    //      follower.isFollowedBy = true
          self.followers.append(follower)
        }
        
//        var followersPfUserObjectIDs = [String]()
//        for follow in results {
//          followersPfUserObjectIDs.append((follow["from"] as! PFUser).objectId!)
//        }
//        for (socIndex, socialNetwork) in self.allFriends.enumerate() {
//          for (userIndex, _) in socialNetwork.enumerate() {
//            if followersPfUserObjectIDs.contains((self.allFriends[socIndex][userIndex].pfUser?.objectId)!) {
//              self.allFriends[socIndex][userIndex].isFollowedBy = true
//            } else {
//              self.allFriends[socIndex][userIndex].isFollowedBy = false
//            }
//          }
//        }
        
      mainTask.setResult(nil)
      }
    }
    return mainTask.task
  }


// ======================================================= //
// MARK: - Linked accounts - Log In
// ======================================================= //
  

func loginWithFacebook() -> BFTask {
  let mainTask = BFTaskCompletionSource()
  
  let fbLoginManager = FBSDKLoginManager()
  fbLoginManager.loginBehavior = FBSDKLoginBehavior.Web
  fbLoginManager.logInWithReadPermissions(["email", "public_profile", "user_friends"],
    fromViewController: UIViewController.currentViewController(),
    handler: {
      (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
      if error == nil && result.token != nil {
        // logged in -> wait for profile to arrive
        
        self.loginLoadingStateDelegate?.didStartNetworingActivity()
        NSNotificationCenter.defaultCenter().addObserver(self, name: FBSDKProfileDidChangeNotification, object: nil) { (observer, notification) -> Void in
          if PFUser.currentUser() == nil {
            CurrentUser.resetSharedInstance()
          }
          self.didReceiveFacebookProfile().continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
            return CurrentUser.sharedCurrentUser().loadFacebookFriends()
          }).continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
            if let error = task.error {
              mainTask.setError(error)
            } else {
              self.loginLoadingStateDelegate?.didEndNetworingActivity()
              mainTask.setResult(nil)
            }
            return nil
          })
        }
        
      } else if let error = error {
        // process error
        mainTask.setError(error)
      }
  })
  return mainTask.task
}



private func didReceiveFacebookProfile() -> BFTask {
  
  let mainTask = BFTaskCompletionSource()
  if FBSDKAccessToken.currentAccessToken() != nil {   // Did FB log in or log out?  (FBSDKProfile.enableUpdatesOnAccessTokenChange(true) triggers for login and logout)
    if PFUser.currentUser() == nil {                  // Link FB if current user is present or log in if nil
      PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken()).continueWithBlock({
        (task: BFTask!) -> AnyObject! in
        if let user = task.result as? PFUser {
          if user.isNew {
           return self.registerWithFacebook(user)
          } else {
            // successfully logged in
            mainTask.setResult(nil)
            return nil
          }
        }
        return nil
      }).continueWithBlock({ (task: BFTask) -> AnyObject? in
        mainTask.setResult(nil)
        return nil
      })
    } else {  // Linking FB profile to currently logged user
        PFUser.currentUser()?["FBID"] = FBSDKProfile.currentProfile().userID
        PFUser.currentUser()?["FBAccessToken"] = FBSDKAccessToken.currentAccessToken().tokenString
        PFUser.currentUser()?.saveInBackground().continueWithBlock({ (task: BFTask) -> AnyObject? in
          if task.error == nil {
            // successfully linked FB profile to currently logged user
            mainTask.setResult(nil)
          }
          return nil
        })
      }
  }
  return mainTask.task
}

  
  
  private func registerWithFacebook(user: PFUser) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let smallProfileImage = FBSDKProfile.currentProfile().imageURLForPictureMode(FBSDKProfilePictureMode.Normal, size: CGSizeMake(100, 100))
    let bigProfileImage = FBSDKProfile.currentProfile().imageURLForPictureMode(FBSDKProfilePictureMode.Normal, size: CGSizeMake(600, 600))
    
    user.username = "\(FBSDKProfile.currentProfile().firstName.lowercaseString)_\(FBSDKProfile.currentProfile().lastName.lowercaseString)"
    user["smallProfileImage"] = "https://graph.facebook.com/\(smallProfileImage)"
    user["bigProfileImage"] = "https://graph.facebook.com/\(bigProfileImage)"
    user["FBID"] = FBSDKProfile.currentProfile().userID
    user["authID"] = "FB" + FBSDKProfile.currentProfile().userID
    user["FBAccessToken"] = FBSDKAccessToken.currentAccessToken().tokenString
    
    PFFacebookUtils.linkUserInBackground(user, withAccessToken: FBSDKAccessToken.currentAccessToken()).continueWithBlock({
      (task: BFTask!) -> AnyObject! in
      if task.error == nil {
        // successfully linked user
        mainTask.setResult(nil)
      } else {
        if task.error!.code == 202 {
          // user with created username(lowercase(first_name)_lowercase(last_name)) already exists. Registering user with appended facebook userID.
          let userID = FBSDKProfile.currentProfile().userID
          user.username?.appendContentsOf(userID.substringWithRange(Range<String.Index>(start: userID.endIndex.advancedBy(-3), end: (userID.endIndex))))
          PFFacebookUtils.linkUserInBackground(user, withAccessToken: FBSDKAccessToken.currentAccessToken()).continueWithBlock({ (task: BFTask) -> AnyObject? in
            mainTask.setResult(nil)
            return nil
          })
        }
      }
      return nil
    })
    
    return mainTask.task
  }


func loginWithInstagram() -> BFTask {
  let mainTask = BFTaskCompletionSource()
  
  let instagramConsumerKey = "1c2e2066145342c3a841bdbdca8e53ae"
  let instagramConsumerSecret = "db9f79ad45b04fc09e8222645cb713b2"
  let instagramAuthorizeURL = "https://api.instagram.com/oauth/authorize"
  
  let auth = OAuth2Swift(
    consumerKey:    instagramConsumerKey,
    consumerSecret: instagramConsumerSecret,
    authorizeUrl:   instagramAuthorizeURL,
    responseType:   "token"
  )
  
  auth.authorize_url_handler = WebVC()

  auth.authorizeWithCallbackURL(
    NSURL(string: "oauth-swift://oauth-callback/instagram")!,
    scope: "likes+comments",
    state:"INSTAGRAM",
    success: {
      credential, response, parameters in
      NSNotificationCenter.defaultCenter().addObserver(self, name: INSTAGRAM_SDK_LOGIN_WEBVIEW_DIDDISAPPEAR, object: nil, handler: { (observer, notification) -> Void in
        self.loginLoadingStateDelegate?.didStartNetworingActivity()
      })
      let engine = InstagramEngine.sharedEngine()
      engine.accessToken = credential.oauth_token
      self.linkedAccountsKeychain["instagram"] = credential.oauth_token
      
      engine.getSelfUserDetailsWithSuccess({
        (user: InstagramUser!) -> Void in
        
        if PFUser.currentUser() == nil {
          
          let userName =   user.username
          let userID =     user.Id
          let smallPhoto = user.profilePictureURL!
          let bigPhoto =   user.profilePictureURL!
          
          PFQuery.usernameIfRegistered("INSTM\(userID)").continueWithBlock({
            (task: BFTask!) -> AnyObject! in
            if task.error == nil, let username = task.result as? String {
              
              PFUser.logInWithUsernameInBackground(username, password: "").continueWithBlock({
                (task: BFTask!) -> AnyObject! in
                if task.error == nil {
                  self.pfUser["INSTMAccessToken"] = credential.oauth_token
                  self.pfUser.saveEventually()
                  CurrentUser.resetSharedInstance()
                  BFTask(forCompletionOfAllTasks: [LinkedAccount.updateInstagram(), self.loadInstagramFriends()])
                    .continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                      self.loginLoadingStateDelegate?.didEndNetworingActivity()
                      mainTask.setResult(nil)
                      return nil
                    })
                } else {
                  // process error
                }
                return nil
              })
              
            } else {
              
              let user = PFUser()
              user.username = userName
              user.password = ""
              user["authID"] = "INSTM\(userID)"
              user["INSTMID"] = userID
              user["smallProfileImage"] = "\(smallPhoto)"
              user["bigProfileImage"] = "\(bigPhoto)"
              user["INSTMAccessToken"] = credential.oauth_token
              
              user.signUpInBackground().continueWithBlock({
                (task: BFTask!) -> AnyObject! in
                if task.error == nil {
                  CurrentUser.resetSharedInstance()
                  mainTask.setResult(nil)
                } else {
                  switch task.error!.code {
                  case 202:   // parse: "username already taken"
                    CurrentUser.resetSharedInstance()
                    self.register("\(userID)", AndUser: user)
                  default: break
                  }
                }
                return nil
              })
              
            }
            return nil
            
          })
          
          
        } else {
          
          PFUser.currentUser()?["INSTMID"] = user.Id
          PFUser.currentUser()?["INSTMAccessToken"] = credential.oauth_token
          PFUser.currentUser()?.saveEventually()
          BFTask(forCompletionOfAllTasks: [LinkedAccount.updateInstagram(), self.loadInstagramFriends()])
          .continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            self.loginLoadingStateDelegate?.didEndNetworingActivity()
            mainTask.setResult(nil)
            return nil
          })
          
          
        }
        
        }, failure: { (error: NSError!, errorCode: Int) -> Void in
          
      })
    },
    failure: {(error:NSError!) -> Void in
      
  })
  
  return mainTask.task
}

  
func loginWithVkontakte() -> BFTask {
  let mainTask = BFTaskCompletionSource()
  if !VKSdk.vkAppMayExists() {
    NSNotificationCenter.defaultCenter().addObserver(self, name: VKSDK_ACCESS_AUTHORIZATION_STARTED, object: nil) { (observer, notification) -> Void in
      if PFUser.currentUser() == nil {
        CurrentUser.resetSharedInstance()
      }
      self.loginLoadingStateDelegate?.didStartNetworingActivity()
      NSNotificationCenter.defaultCenter().addObserver(self, name: VKSDK_ACCESS_AUTHORIZATION_SUCCEEDED, object: nil) { (observer, notification) -> Void in
        BFTask(forCompletionOfAllTasks: [LinkedAccount.updateVkontakte(), self.loadVkontakteFriends()])
        .continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
            self.loginLoadingStateDelegate?.didEndNetworingActivity()
            mainTask.setResult(nil)
            return nil
          })
      }
    }
  } else {
    NSNotificationCenter.defaultCenter().addObserver(self, name: VKSDK_ACCESS_AUTHORIZATION_SUCCEEDED, object: nil) { (observer, notification) -> Void in
      if PFUser.currentUser() == nil {
        CurrentUser.resetSharedInstance()
      }
      BFTask(forCompletionOfAllTasks: [LinkedAccount.updateVkontakte(), self.loadVkontakteFriends()])
      .continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
        self.loginLoadingStateDelegate?.didEndNetworingActivity()
        mainTask.setResult(nil)
        return nil
      })
    }
  }
  VKSdk.authorize(VKSDK_AUTH_PERMISSIONS)
  return mainTask.task
  }


// ======================================================= //
// MARK: - Linked accounts - Log Out
// ======================================================= //

  
  func logoutFromFacebook() {
    FBSDKLoginManager().logOut()
    pfUser["FBID"] = NSNull()
    pfUser["FBAccessToken"] = NSNull()
    pfUser.saveEventually()
    facebookFriends.removeAll(keepCapacity: false)
    self.updateFollowFriendsCells()
  }
  
  func logoutFromVkontakte() {
    VKSdk.forceLogout()
    pfUser["VKID"] = NSNull()
    pfUser["VKAccessToken"] = NSNull()
    pfUser.saveEventually()
    vkontakteFriends.removeAll(keepCapacity: false)
    LinkedAccount.updateVkontakte()
    updateFollowFriendsCells()
  }
  
  func logoutFromInstagram() {
    InstagramEngine.sharedEngine().logout()
    self.linkedAccountsKeychain["instagram"] = nil
    pfUser["INSTMID"] = NSNull()
    pfUser["INSTMAccessToken"] = NSNull()
    pfUser.saveEventually()
    instagramFriends.removeAll(keepCapacity: false)
    LinkedAccount.updateInstagram()
    updateFollowFriendsCells()
  }
  
  
// ======================================================= //
// MARK: - Loading linked accounts` friends
// ======================================================= //
  
  func loadInstagramFriends() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let instmEngine = InstagramEngine.sharedEngine()
    let instmKeychain = self.linkedAccountsKeychain
    if instmKeychain["instagram"] != nil {
    instmEngine.accessToken = instmKeychain["instagram"]
    instmEngine.getSelfUserDetailsWithSuccess({ (currentUser: InstagramUser!) -> Void in
      instmEngine.getUsersFollowedByUser(currentUser.Id, withSuccess: {(
        users: [InstagramUser], pageInfo:InstagramPaginationInfo) -> Void in
          var userIDs = [String]()
          for user in users {
            userIDs.append(user.Id)
          }
          let query = PFUser.query()
          query?.whereKey("INSTMID", containedIn: userIDs)
          query?.whereKey("INSTMID", notEqualTo: currentUser.Id)
          query?.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
            let foundUsers = results as! [PFUser]
            self.instagramFriends.removeAll(keepCapacity: false)
            for user in foundUsers {
              let follower = User(thePfUser: user)
              self.instagramFriends.append(follower)
            }
            self.updateFollowFriendsCells()
            mainTask.setResult(nil)
          })
        }, failure: { (error: NSError!, errorCode: Int) -> Void in
      })
      }) { (error: NSError!, errorCode: Int) -> Void in
    }
    } else {
      mainTask.setResult(nil)
    }
    return mainTask.task
  }
  
  
  
  func loadVkontakteFriends() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    if VKSdk.isLoggedIn() {
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
            query?.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
              if error == nil {
                let foundUsers = results as! [PFUser]
                self.vkontakteFriends.removeAll(keepCapacity: false)
                for user in foundUsers {
                  let follower = User(thePfUser: user)
                  self.vkontakteFriends.append(follower)
                }
                
                self.updateFollowFriendsCells()
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

  func loadFacebookFriends() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    
    if FBSDKAccessToken.currentAccessToken() != nil && FBSDKProfile.currentProfile() != nil {
      
      let graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: nil, HTTPMethod: "GET")
      
      graphRequest.startWithCompletionHandler({
        (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
        
        if error == nil {
          
          let json = JSON(result)
          var fbList = [String]()
          for (_, subJson) in json["data"] {
            fbList.append(subJson["id"].stringValue)
          }
          let query = PFUser.query()
          query?.whereKey("FBID", containedIn: fbList)
          query?.whereKey("FBID", notEqualTo: FBSDKProfile.currentProfile().userID)
      
          query?.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
            if error == nil, let foundUsers = results as? [PFUser] {
              self.facebookFriends.removeAll(keepCapacity: false)
              for user in foundUsers {
                let follower = User(thePfUser: user)
                self.facebookFriends.append(follower)
              }
              mainTask.setResult(nil)
            }
          })
        }
        else {
        }
      })
      
    } else {
      mainTask.setResult(nil)
    }
    
    return mainTask.task
  }
  
  
// ======================================================= //
// MARK: - VK SDK
// ======================================================= //

func getVKUserID() -> BFTask {
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

func getVKUsername() -> BFTask {
  let task = BFTaskCompletionSource()
  let vkReq = VKApi.users().get()
  vkReq.executeWithResultBlock({ (response: VKResponse!) -> Void in
    let json = JSON(response.json)
    if let firstName = json[0]["first_name"].string, let lastName = json[0]["last_name"].string {
      let username: String = firstName + " " + lastName
      task.setResult(username)
    } else {
      task.setResult("")
    }
    }) { (error: NSError!) -> Void in
      task.setError(error)
  }
  return task.task
}
  
// ======================================================= //
// MARK: - Instagram SDK
// ======================================================= //
  
  func instagramGetSelfUserDetailsWithSuccess() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    InstagramEngine.sharedEngine().getSelfUserDetailsWithSuccess({ (currentUser: InstagramUser!) -> Void in
      mainTask.setResult(currentUser)
      }) { (error: NSError!, errorCode: Int) -> Void in
        mainTask.setError(error)
    }
    return mainTask.task
  }
  
// ======================================================= //
// MARK: - Convenience
// ======================================================= //
  
  func register(WithUserID: String, AndUser: PFUser) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let user = AndUser
    let userID = WithUserID
    user.username?.appendContentsOf(userID.substringWithRange(Range<String.Index>(start: userID.endIndex.advancedBy(-3), end: (userID.endIndex))))
    user.signUpInBackgroundWithBlock({ (result: Bool, error: NSError?) -> Void in
      if error == nil {
        mainTask.setResult(nil)
      }
    })
    return mainTask.task
  }
  
  func checkLinkedAccountsFollowingFriends() {
    var followersPfUserObjectIDs = [String]()
    for follow in following {
      followersPfUserObjectIDs.append(follow.pfUser.objectId!)
    }
    for (socIndex, socialNetwork) in allFriends.enumerate() {
      for (userIndex, _) in socialNetwork.enumerate() {
        if followersPfUserObjectIDs.contains(allFriends[socIndex][userIndex].pfUser.objectId!) {
          allFriends[socIndex][userIndex].isFollowed = true
        } else {
          allFriends[socIndex][userIndex].isFollowed = false
        }
      }
    }
    
  }
  
  func updateFollowFriendsCells() {
    self.followFriendsData.removeAll(keepCapacity: false)
    self.checkLinkedAccountsFollowingFriends()
    if self.facebookFriends.count != 0 {
      let fbFriends = FollowFriends(
        theLocalIconName: "facebook",
        theServiceName: "Facebook",
        theNumberOfFriends: self.facebookFriends.count
      )
      self.followFriendsData.append(fbFriends)
    }
    if self.instagramFriends.count != 0 {
      let instagramFriends = FollowFriends(
        theLocalIconName: "instagram",
        theServiceName: "Instagram",
        theNumberOfFriends: self.instagramFriends.count
      )
      self.followFriendsData.append(instagramFriends)
    }
    if self.vkontakteFriends.count != 0 {
      let vkFriends = FollowFriends(
        theLocalIconName: "vk",
        theServiceName: "VKontakte",
        theNumberOfFriends: self.vkontakteFriends.count
      )
      self.followFriendsData.append(vkFriends)
    }
    followFriendsDelegate?.didUpdateFollowFriendsData()
  }
  
  func loadLinkedAccountsFriends() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    return BFTask(forCompletionOfAllTasks: [loadVkontakteFriends(), loadFacebookFriends(), loadInstagramFriends()])
    .continueWithBlock { (task: BFTask!) -> AnyObject! in
      NSNotificationCenter.defaultCenter().postNotificationName("didFinishLoadingLinkedAccountsData", object: nil)
      mainTask.setResult(nil)
      return nil
    }
  }
  
  override func updateAllProfileData() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    return BFTask(forCompletionOfAllTasks: [
              loadLinkedAccountsFriends(),
              loadFollowingUsers(),
              loadFollowers(),
              loadUserPosts(),
              loadWatchedPosts()
            ])
    .continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
   //   self.checkIfFollowersAreFollowed()
      self.checkLinkedAccountsFollowingFriends()
      self.updateFollowFriendsCells()
      NSNotificationCenter.defaultCenter().postNotificationName("didFinishLoadingStartupData", object: nil)
      mainTask.setResult(nil)
      return nil
    }
  }  
}













