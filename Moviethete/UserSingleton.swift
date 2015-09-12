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
import KeychainAccess

public struct UserSingelton {
  
  static var sharedInstance = UserSingelton()
  
  var allFriends = [[User]]()
  var followFriendsData = [FollowFriends]()
  var instagramKeychain = Keychain(server: "https://api.instagram.com/oauth/authorize", protocolType: .HTTPS)
  var facebookFriends = [User]()
  var vkontakteFriends = [User]()
  var instagramFriends = [User]()
  
  // FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
  //  NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFacebookProfile:", name: FBSDKProfileDidChangeNotification, object: nil)
  
  
  mutating func loadFollowFriendsData() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    UserSingelton.sharedInstance.allFriends.removeAll(keepCapacity: false)
    var ff = FollowFriends.sharedInstance
    let tasks = BFTask(forCompletionOfAllTasks: [loadVkontakteFriends(), loadFacebookFriends(), loadInstagramFriends(), ff.loadLinkedAccountsData()])
    tasks.continueWithBlock { (task: BFTask!) -> AnyObject! in
      UserSingelton.sharedInstance.followFriendsData.removeAll(keepCapacity: false)
      UserSingelton.sharedInstance.loadFollowFriendsCells().continueWithBlock({ (task: BFTask!) -> AnyObject! in
        mainTask.setResult(nil)
        return nil
     })
      return nil
    }
    
    return mainTask.task
  }
  
  
  mutating func loadInstagramFriends() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let instmEngine = InstagramEngine.sharedEngine()
    let instmKeychain = UserSingelton.sharedInstance.instagramKeychain
    if instmKeychain["instagram"] != nil {
    instmEngine.accessToken = instmKeychain["instagram"]
    instmEngine.getSelfUserDetailsWithSuccess({ (currentUser: InstagramUser!) -> Void in
      instmEngine.getUsersFollowedByUser(currentUser.Id, withSuccess: {(
        media: [AnyObject]!, pageInfo:InstagramPaginationInfo!) -> Void in
        if let users = media as? [InstagramUser] {
          var userIDs = [String]()
          for user in users {
            userIDs.append(user.Id)
          }
          let query = PFUser.query()
          query?.whereKey("INSTMID", containedIn: userIDs)
          query?.whereKey("INSTMID", notEqualTo: currentUser.Id)
          query?.findObjectsInBackgroundWithBlock({ (results: [AnyObject]?, error: NSError?) -> Void in
            let foundUsers = results as! [PFUser]
            UserSingelton.sharedInstance.instagramFriends.removeAll(keepCapacity: false)
            for user in foundUsers {
              let follower = User(theUsername: user.username!, theProfileImageURL: user["smallProfileImage"] as! String)
              UserSingelton.sharedInstance.instagramFriends.append(follower)
            }
            if UserSingelton.sharedInstance.instagramFriends.count > 0 {
              UserSingelton.sharedInstance.allFriends.append(UserSingelton.sharedInstance.instagramFriends)
            }
            mainTask.setResult(nil)
          })
        }
        }, failure: { (error: NSError!, errorCode: Int) -> Void in
      })
      }) { (error: NSError!, errorCode: Int) -> Void in
    }
    } else {
      mainTask.setResult(nil)
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
          theServiceName: "VKontakte"
        )
        UserSingelton.sharedInstance.followFriendsData.append(vkFriends)
      }
    }
    
    
    if InstagramEngine.sharedEngine().accessToken != nil {
      if UserSingelton.sharedInstance.instagramFriends.count != 0 {
        let instagramFriends = FollowFriends(
          theLocalIconName: "instagram",
          theNumberOfFriends: UserSingelton.sharedInstance.instagramFriends.count,
          theServiceName: "Instagram"
        )
        UserSingelton.sharedInstance.followFriendsData.append(instagramFriends)
      }
    }

    
    mainTask.setResult(nil)
    
    return mainTask.task
    
  }
  
  
  
  mutating func loadFacebookFriends() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    
    if FBSDKAccessToken.currentAccessToken() != nil && FBSDKProfile.currentProfile() != nil {
      
    let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields" : "friends"], HTTPMethod: "GET")
     
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
        }
      })
      
    } else {
      mainTask.setResult(nil)
    }
    
    return mainTask.task
  }

  
  
   func loginWithFacebook() {
 //   NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFacebookProfile:", name: FBSDKProfileDidChangeNotification, object: nil)
    
    let fbLoginManager = FBSDKLoginManager()
    fbLoginManager.loginBehavior = FBSDKLoginBehavior.Web
    fbLoginManager.logInWithReadPermissions(["email", "public_profile", "user_friends"], handler: {
      (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
      if error == nil && result.token != nil {
        // logged in
      } else {
        // process error
      }
    })
  }
  
  
  func didReceiveFacebookProfile() -> BFTask {
    
    let mainTask = BFTaskCompletionSource()
    if PFUser.currentUser() == nil {
      if FBSDKAccessToken.currentAccessToken() != nil {               // did FB log in or log out?
        
        PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken()).continueWithBlock({
          (task: BFTask!) -> AnyObject! in
          if let user = task.result as? PFUser {
            if user.isNew {
              
              let smallProfileImage = FBSDKProfile.currentProfile().imagePathForPictureMode(FBSDKProfilePictureMode.Normal, size: CGSizeMake(100, 100))
              let bigProfileImage = FBSDKProfile.currentProfile().imagePathForPictureMode(FBSDKProfilePictureMode.Normal, size: CGSizeMake(600, 600))
              user.username = "\(FBSDKProfile.currentProfile().firstName.lowercaseString)_\(FBSDKProfile.currentProfile().lastName.lowercaseString)"
              user["smallProfileImage"] = "https://graph.facebook.com/\(smallProfileImage)"
              user["bigProfileImage"] = "https://graph.facebook.com/\(bigProfileImage)"
              user["FBID"] = FBSDKProfile.currentProfile().userID
              user["authID"] = "FB" + FBSDKProfile.currentProfile().userID
              
              PFFacebookUtils.linkUserInBackground(user, withAccessToken: FBSDKAccessToken.currentAccessToken()).continueWithBlock({
                (task: BFTask!) -> AnyObject! in
                if task.error == nil {
                  // successfully linked user
                  mainTask.setResult(nil)
                } else {
                  switch task.error.code {
                  case 202:
                    let userID = FBSDKProfile.currentProfile().userID
                    user.username?.appendContentsOf(userID.substringWithRange(Range<String.Index>(start: userID.endIndex.advancedBy(-3), end: (userID.endIndex))))
                    PFFacebookUtils.linkUserInBackground(user, withAccessToken: FBSDKAccessToken.currentAccessToken())
                      mainTask.setResult(nil)
                  default: break
                  }
                }
                return nil
              })
            }
              mainTask.setResult(nil)
          }
          return nil
        })
      } else {
        print("Uh oh. There was an error logging in.")
      }
    }
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
        
        let engine = InstagramEngine.sharedEngine()
        engine.accessToken = credential.oauth_token
        UserSingelton.sharedInstance.instagramKeychain["instagram"] = credential.oauth_token
        
        engine.getSelfUserDetailsWithSuccess({
          (user: InstagramUser!) -> Void in
          let userName =   user.username
          let userID =     user.Id
          let smallPhoto = user.profilePictureURL
          let bigPhoto =   user.profilePictureURL
          
          self.getUsernameifRegistered("INSTM\(userID)").continueWithBlock({
            (task: BFTask!) -> AnyObject! in
            if task.error == nil, let username = task.result as? String {
              
              PFUser.logInWithUsernameInBackground(username, password: "").continueWithBlock({
                (task: BFTask!) -> AnyObject! in
                if task.error == nil {
                  mainTask.setResult(nil)
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
              
              user.signUpInBackground().continueWithBlock({
                (task: BFTask!) -> AnyObject! in
                if task.error == nil {
                  mainTask.setResult(nil)
                } else {
                  switch task.error.code {
                  case 202:   // parse: "username already taken"
                    self.extendUsernameWithUserIDAndRegister("\(userID)", user: user)
                  default: break
                  }
                }
                return nil
              })
              
            }
            return nil
          })
          }, failure: { (error: NSError!, errorCode: Int) -> Void in
            
        })
      },
      failure: {(error:NSError!) -> Void in
      
    })
    return mainTask.task
  }

  
  func didReceiveNewVKToken() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    if VKSdk.isLoggedIn() {
      let vkReq = VKApi.users().get(["fields" : "photo_100, photo_200_orig"])
      vkReq.executeWithResultBlock({
        (response: VKResponse!) -> Void in
        let json = JSON(response.json)
        if let
          firstName =  json[0]["first_name"].string,
          lastName =   json[0]["last_name"].string,
          userID =     json[0]["id"].number,
          smallPhoto = json[0]["photo_100"].string,
          bigPhoto   = json[0]["photo_200_orig"].string {
            
            self.getUsernameifRegistered("VK\(userID)").continueWithBlock({
              (task: BFTask!) -> AnyObject! in
              if task.error == nil, let username = task.result as? String {
                
                PFUser.logInWithUsernameInBackground(username, password: "").continueWithBlock({
                  (task: BFTask!) -> AnyObject! in
                  if task.error == nil {
                    mainTask.setResult(nil)
                  } else {
                    // process error
                  }
                  return nil
                })
                
              } else {
                
                let user = PFUser()
                user.username = "\(firstName)_\(lastName)".lowercaseString
                user.password = ""
                user["authID"] = "VK\(userID)"
                user["VKID"] = "\(userID)"
                user["smallProfileImage"] = smallPhoto
                user["bigProfileImage"] = bigPhoto
                user.signUpInBackground().continueWithBlock({
                  (task: BFTask!) -> AnyObject! in
                  if task.error == nil {
                    mainTask.setResult(nil)
                  } else {
                    switch task.error {
                    case 202:   // parse: "username already taken"
                      self.extendUsernameWithUserIDAndRegister("\(userID)", user: user)
                    default: break
                    }
                  }
                  return nil
                })
                
              }
              
              return nil
              
            })
        }
        },  errorBlock: {
          (error: NSError!) -> Void in
          
      })
    }
    return mainTask.task
  }
  
  
  
  
  
  
  
  
  
  
  
  // MARK: - Utility
  func getUsernameifRegistered(ID: String) -> BFTask {
    let task = BFTaskCompletionSource()
    let query = PFUser.query()
    query?.whereKey("authID", equalTo: ID)
    query?.getFirstObjectInBackgroundWithBlock({
      (foundUser: PFObject?, error: NSError?) -> Void in
      if error == nil, let user = foundUser as? PFUser {
        task.setResult(user.username!)
      }
      else {
        task.setResult(nil)
      }
    })
    return task.task
  }
  
  
  func extendUsernameWithUserIDAndRegister(userID: String, user: PFUser){
    user.username?.appendContentsOf(userID.substringWithRange(Range<String.Index>(start: userID.endIndex.advancedBy(-3), end: (userID.endIndex))))
    user.signUpInBackgroundWithBlock({ (result: Bool, error: NSError?) -> Void in
      if error == nil {
 //       self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
      }
    })
  }

  
  
  
  
  
  
}





