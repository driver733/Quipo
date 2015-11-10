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
//import FontBlaster
import Parse
import ParseFacebookUtilsV4
import Bolts
import KeychainAccess

extension UserSingelton {
  
  
}



public struct UserSingelton {
  
  static var sharedInstance = UserSingelton()
  
  var allFriends = [[User]]()
  var followFriendsData = [FollowFriends]()
  var linkedAccountsKeychain = Keychain(server: "https://api.instagram.com/oauth/authorize", protocolType: .HTTPS)
  var facebookFriends = [User]()
  var vkontakteFriends = [User]()
  var instagramFriends = [User]()
  
  var followedUsers = [String]()
  var unfollowedUsers = [String]()
  
  
  var followers = [User]()
  var following = [User]()
  
  
  var isFromDetailedVC = false
  var hasLoadedStartupData = false
  var shouldUpdateLinkedAccounts = false
  var shouldUpdateFollowFriends = true

  // MARK: - Parse
  
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
        UserSingelton.sharedInstance.linkedAccountsKeychain["instagram"] = instagramAccessToken
        let engine = InstagramEngine.sharedEngine()
        engine.accessToken = instagramAccessToken
      }
    }
  }
  
  
  func checkIfVkontakteAccessTokenIsPresent() {
    if let vkAccessToken = PFUser.currentUser()?["VKAccessToken"] as? String, vkUserID = PFUser.currentUser()?["VKID"] as? String  {
      let vkAccessToken = VKAccessToken(token: vkAccessToken, secret: "PuLAVPrHRvxkl24PWKDm", userId: vkUserID)
      VKSdk.setAccessToken(vkAccessToken)
    }
  }
  
  
  
  
  

  
  func updateUserSubscriptions(followedUsersObjectIDs: [String], unfollowedUsersObjectIDs: [String]) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    if followedUsersObjectIDs.count != 0 || unfollowedUsersObjectIDs.count != 0 {
      PFCloud.callFunctionInBackground("updateUserSubscriptions", withParameters:
        ["currentUserObjectId" :      (PFUser.currentUser()?.objectId)!,
         "followedUsersObjectIDs" :   UserSingelton.sharedInstance.followedUsers,
         "unFollowedUsersObjectIDs" : UserSingelton.sharedInstance.unfollowedUsers]
        ).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            return UserSingelton.sharedInstance.updateData()
        }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            UserSingelton.sharedInstance.followedUsers.removeAll(keepCapacity: false)
            UserSingelton.sharedInstance.unfollowedUsers.removeAll(keepCapacity: false)
            mainTask.setResult(nil)
            return nil
      }
    } else {
      mainTask.setResult(nil)
    }
    return mainTask.task
  }
  
  
  
  
  
  
  
  func checkCurrentUserFollowingUsers() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let query = PFQuery(className: "Follow")
    query.whereKey("from", equalTo: PFUser.currentUser()!)
    query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
      
      if let results = results {
        
        
      
      var followersPfUserObjectIDs = [String]()
      for follow in results {
        followersPfUserObjectIDs.append((follow["to"] as! PFUser).objectId!)
      }
      
  //    followersPfUserObjectIDs = Array(Set(followersPfUserObjectIDs))
        
        
      for var i = 0; i < UserSingelton.sharedInstance.allFriends.count; i++ {
        for var j = 0; j < UserSingelton.sharedInstance.allFriends[i].count; j++ {
          
          if (followersPfUserObjectIDs.contains((UserSingelton.sharedInstance.allFriends[i][j].pfUser?.objectId!)!)) {
            UserSingelton.sharedInstance.allFriends[i][j].isFollowed = true
          } else {
            UserSingelton.sharedInstance.allFriends[i][j].isFollowed = false
          }
          
        }
      }
      mainTask.setResult(nil)
      }
    }
    return mainTask.task
  }
  
  
  func checkCurrentUsersFollowers() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let query = PFQuery(className: "Follow")
    query.whereKey("to", equalTo: PFUser.currentUser()!)
    query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
      
      if let results = results {
        
      var followersPfUserObjectIDs = [String]()
      for follow in results {
        followersPfUserObjectIDs.append((follow["from"] as! PFUser).objectId!)
      }
        
     //  followersPfUserObjectIDs = Array(Set(followersPfUserObjectIDs))
        
      for (socIndex, socialNetwork) in UserSingelton.sharedInstance.allFriends.enumerate() {
        for (userIndex, _) in socialNetwork.enumerate() {
          
          if followersPfUserObjectIDs.contains((UserSingelton.sharedInstance.allFriends[socIndex][userIndex].pfUser?.objectId)!) {
            UserSingelton.sharedInstance.allFriends[socIndex][userIndex].isFollowedBy = true
          } else {
            UserSingelton.sharedInstance.allFriends[socIndex][userIndex].isFollowedBy = false
          }
          
        }
      }
        
        
      mainTask.setResult(nil)
      }
    }
    return mainTask.task
  }

  
  
  
  
  
// MARK: - Linked accounts Log In

func loginWithFacebook(fromViewController: UIViewController) {
  let fbLoginManager = FBSDKLoginManager()
  fbLoginManager.logInWithReadPermissions(["email", "public_profile", "user_friends"],
    fromViewController: fromViewController,
    handler: {
      (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
      if error == nil && result.token != nil {
        // logged in
      } else {
        // process error
        
      }
  })
  
}



mutating func didReceiveFacebookProfile() -> BFTask {
  
  let mainTask = BFTaskCompletionSource()
  if PFUser.currentUser() == nil {                      // Link FB or log in through it?
    if FBSDKAccessToken.currentAccessToken() != nil {               // Did FB log in or log out?
      
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
            user["FBAccessToken"] = FBSDKAccessToken.currentAccessToken().tokenString
            
    
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
    
    
  } else if FBSDKAccessToken.currentAccessToken() != nil {  // Linking or unlinking FB?
    PFUser.currentUser()?["FBID"] = FBSDKProfile.currentProfile().userID
    PFUser.currentUser()?["FBAccessToken"] = FBSDKAccessToken.currentAccessToken().tokenString
    PFUser.currentUser()?.saveInBackground()
    loadFacebookFriends().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
      return UserSingelton.sharedInstance.updateData()
    }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
      mainTask.setResult(nil)
      return nil
    })
  }
  return mainTask.task
}




mutating func loginWithInstagram() -> BFTask {
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
      UserSingelton.sharedInstance.linkedAccountsKeychain["instagram"] = credential.oauth_token
      
      engine.getSelfUserDetailsWithSuccess({
        (user: InstagramUser!) -> Void in
        
        if PFUser.currentUser() == nil {
          
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
                  PFUser.currentUser()?["INSTMAccessToken"] = credential.oauth_token
                  PFUser.currentUser()?.saveInBackground()
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
              user["INSTMAccessToken"] = credential.oauth_token
              
              user.signUpInBackground().continueWithBlock({
                (task: BFTask!) -> AnyObject! in
                if task.error == nil {
                  mainTask.setResult(nil)
                } else {
                  switch task.error.code {
                  case 202:   // parse: "username already taken"
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
          PFUser.currentUser()?.saveInBackground()
          self.loadInstagramFriends().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            return UserSingelton.sharedInstance.updateData()
          }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
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


mutating func didReceiveNewVKToken() -> BFTask {
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
      
      if PFUser.currentUser() == nil {
        
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
                user["VKAccessToken"] = VKSdk.getAccessToken().accessToken
                user.signUpInBackground().continueWithBlock({
                  (task: BFTask!) -> AnyObject! in
                  if task.error == nil {
                    mainTask.setResult(nil)
                  } else {
                    switch task.error {
                    case 202:   // parse: "username already taken"
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
        PFUser.currentUser()?["VKID"] = "\(userID)"
        PFUser.currentUser()?["VKAccessToken"] = VKSdk.getAccessToken().accessToken
        PFUser.currentUser()?.saveInBackground()
        self.loadVkontakteFriends().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
          return UserSingelton.sharedInstance.updateData()
        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
          mainTask.setResult(nil)
          return nil
        })
        
      }
          
      }
      
      
      },  errorBlock: {
        (error: NSError!) -> Void in
        
    })
  }
  return mainTask.task
}





// MARK: - Linked accounts Log Out
  

  
  
  func logoutFromFacebook() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    FBSDKLoginManager().logOut()
    UserSingelton.sharedInstance.sortAllFriends()
    PFUser.currentUser()?["FBID"] = ""
    PFUser.currentUser()?["FBAccessToken"] = ""
    PFUser.currentUser()?.saveInBackground()
    UserSingelton.sharedInstance.updateData().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      mainTask.setResult(nil)
      return nil
    }
    
    return mainTask.task
  }
  
  func logoutFromVkontakte() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    VKSdk.forceLogout()
    UserSingelton.sharedInstance.sortAllFriends()
    PFUser.currentUser()?["VKID"] = ""
    PFUser.currentUser()?["VKAccessToken"] = ""
    PFUser.currentUser()?.saveEventually()
    UserSingelton.sharedInstance.updateData().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      mainTask.setResult(nil)
      return nil
    }
    
    return mainTask.task
  }
  
  func logoutFromInstagram() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    InstagramEngine.sharedEngine().logout()
    UserSingelton.sharedInstance.linkedAccountsKeychain["instagram"] = nil
    PFUser.currentUser()?["INSTMID"] = ""
    PFUser.currentUser()?["INSTMAccessToken"] = ""
    PFUser.currentUser()?.saveInBackground()
    UserSingelton.sharedInstance.sortAllFriends()
    UserSingelton.sharedInstance.updateData().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      mainTask.setResult(nil)
      return nil
    }
    
    return mainTask.task
  }
  
  
// MARK: - Loading linked accounts friends`
  
  
  
  
  
  
  mutating func loadInstagramFriends() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let instmEngine = InstagramEngine.sharedEngine()
    let instmKeychain = UserSingelton.sharedInstance.linkedAccountsKeychain
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
          query?.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
            let foundUsers = results as! [PFUser]
            UserSingelton.sharedInstance.instagramFriends.removeAll(keepCapacity: false)
            for user in foundUsers {
              let follower = User(theUsername: user.username!, theProfileImageURL: user["smallProfileImage"] as! String, thePfUser: user)
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
            query?.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
              if error == nil {
                let foundUsers = results as! [PFUser]
                UserSingelton.sharedInstance.vkontakteFriends.removeAll(keepCapacity: false)
                for user in foundUsers {
                  let follower = User(theUsername: user.username!, theProfileImageURL: user["smallProfileImage"] as! String, thePfUser: user)
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
  
  
  mutating func loadFacebookFriends() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    
    if FBSDKAccessToken.currentAccessToken() != nil && FBSDKProfile.currentProfile() != nil {
      
      let graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields" : "friends"], HTTPMethod: "GET")
      
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
              UserSingelton.sharedInstance.facebookFriends.removeAll(keepCapacity: false)
              for user in foundUsers {
                let follower = User(theUsername: user.username!, theProfileImageURL: user["smallProfileImage"] as! String, thePfUser: user)
                UserSingelton.sharedInstance.facebookFriends.append(follower)
              }
              if UserSingelton.sharedInstance.facebookFriends.count > 0 {
                UserSingelton.sharedInstance.allFriends.append(UserSingelton.sharedInstance.facebookFriends)
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
  
  
// MARK: - VK SDK



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
      task.setResult(nil)
    }
    
    }) { (error: NSError!) -> Void in
      task.setResult(nil)
  }
  return task.task
}

  
  
// MARK: - Instagram SDK
  
  
  func instagramGetSelfUserDetailsWithSuccess() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    InstagramEngine.sharedEngine().getSelfUserDetailsWithSuccess({ (currentUser: InstagramUser!) -> Void in
      mainTask.setResult(currentUser)
      }) { (error: NSError!, errorCode: Int) -> Void in
        mainTask.setResult(error)
    }
    return mainTask.task
  }
  
  
  
  
  
// MARK: - Convenience
  
  
  
  func updateFollowers() {
    UserSingelton.sharedInstance.followers.removeAll(keepCapacity: false)
    for socialNetwork in UserSingelton.sharedInstance.allFriends {
      for friend in socialNetwork {
        if friend.isFollowedBy {
          UserSingelton.sharedInstance.followers.append(friend)
        }
      }
    }
  }
  
  
  
  func updateFollowing() {
    UserSingelton.sharedInstance.following.removeAll(keepCapacity: false)
    for socialNetwork in UserSingelton.sharedInstance.allFriends {
      for friend in socialNetwork {
        if friend.isFollowed {
          UserSingelton.sharedInstance.following.append(friend)
        }
      }
    }
  }
  
  
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
  
  
  mutating func loadFollowFriendsCells() {
    
    UserSingelton.sharedInstance.followFriendsData.removeAll(keepCapacity: false)
    
    if FBSDKAccessToken.currentAccessToken() != nil {
      if UserSingelton.sharedInstance.facebookFriends.count != 0 {
        let fbFriends = FollowFriends(
          theLocalIconName: "facebook",
          theNumberOfFriends: UserSingelton.sharedInstance.facebookFriends.count,
          theServiceName: "Facebook"
        )
        UserSingelton.sharedInstance.followFriendsData.append(fbFriends)
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
    
    
    
  }
  
  
  mutating func loadFollowFriendsData() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    UserSingelton.sharedInstance.allFriends.removeAll(keepCapacity: false)
    let tasks = BFTask(forCompletionOfAllTasks: [loadVkontakteFriends(), loadFacebookFriends(), loadInstagramFriends()])
    tasks.continueWithBlock { (task: BFTask!) -> AnyObject! in
      
      UserSingelton.sharedInstance.followFriendsData.removeAll(keepCapacity: false)
      return UserSingelton.sharedInstance.updateData()
      }.continueWithBlock({ (task: BFTask!) -> AnyObject! in
        mainTask.setResult(nil)
        NSNotificationCenter.defaultCenter().postNotificationName("didFinishLoadingLinkedAccountsData", object: nil)
        return nil
      })
    
    return mainTask.task
  }
  
  
  func sortAllFriends() {
 
    UserSingelton.sharedInstance.allFriends.removeAll(keepCapacity: true)
    
    if FBSDKAccessToken.currentAccessToken() != nil {
      if UserSingelton.sharedInstance.facebookFriends.count > 0 {
        UserSingelton.sharedInstance.allFriends.append(UserSingelton.sharedInstance.facebookFriends)
      }
    }
    
    if InstagramEngine.sharedEngine().accessToken != nil {
      if UserSingelton.sharedInstance.instagramFriends.count > 0 {
        UserSingelton.sharedInstance.allFriends.append(UserSingelton.sharedInstance.instagramFriends)
      }
    }
    
    
    if VKSdk.isLoggedIn() {
      if UserSingelton.sharedInstance.vkontakteFriends.count > 0 {
        UserSingelton.sharedInstance.allFriends.append(UserSingelton.sharedInstance.vkontakteFriends)
      }
    }

 
  }
  
  
  
  
   func updateData() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    UserSingelton.sharedInstance.sortAllFriends()
    UserSingelton.sharedInstance.loadFollowFriendsCells()
    return BFTask(
      forCompletionOfAllTasks: [
        UserSingelton.sharedInstance.checkCurrentUserFollowingUsers(),
        UserSingelton.sharedInstance.checkCurrentUsersFollowers(),
        FollowFriends.sharedInstance.loadLinkedAccountsData(),
        Post.sharedInstance.startLoadingAllUserPosts()
      ]
      ).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        UserSingelton.sharedInstance.updateFollowers()
        UserSingelton.sharedInstance.updateFollowing()
        UserSingelton.sharedInstance.hasLoadedStartupData = true
        NSNotificationCenter.defaultCenter().postNotificationName("didFinishLoadingStartupData", object: nil)
        mainTask.setResult(nil)
        return nil
    }
  }
  
  
  

  
  
}





