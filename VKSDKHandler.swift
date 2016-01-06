//
//  VKDelegateHandler.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 12/16/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import Foundation
import Bolts
import VK_ios_sdk
import SwiftyJSON
import Parse
import Async

let VKSDK_ACCESS_AUTHORIZATION_SUCCEEDED = "VKSDK_ACCESS_AUTHORIZATION_SUCCEEDED"
let VKSDK_ACCESS_AUTHORIZATION_FAILED = "VKSDK_ACCESS_AUTHORIZATION_FAILED"
let VKSDK_ACCESS_AUTHORIZATION_STARTED = "VKSDK_ACCESS_AUTHORIZATION_STARTED"
let VKSDK_AUTH_PERMISSIONS = ["friends","offline","wall"]
let VKSDK_VK_APP_ID = "4991711"

public class VKSDKHandler: NSObject {
  
  public static let sharedInstance = VKSDKHandler()
  let VKSDKInstance = VKSdk.initializeWithAppId(VKSDK_VK_APP_ID)
  
  override init() {
    super.init()
    VKSDKInstance.registerDelegate(self)
    VKSDKInstance.uiDelegate = self
    VKSdk.wakeUpSession(VKSDK_AUTH_PERMISSIONS) { (state: VKAuthorizationState, _) -> Void in
    }
  }
  
  func didFinishVKAuthentication() -> BFTask {
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
              // checking if tnere is an account that has a matching linked VK account
              PFQuery.usernameIfRegistered("VK\(userID)").continueWithBlock({
                (task: BFTask!) -> AnyObject! in
                if task.error == nil, let username = task.result as? String {
                  PFUser.logInWithUsernameInBackground(username, password: "").continueWithBlock({
                    (task: BFTask!) -> AnyObject! in
                    if task.error == nil {
                      Async.main {
                        mainTask.setResult(nil)
                      }
                    } else {
                      // process error
                    }
                    return nil
                  })
                } else {
                  // signing up user with VK Account
                  let user = PFUser()
                  user.username = "\(firstName)_\(lastName)".lowercaseString
                  user.password = ""
                  user["authID"] = "VK\(userID)"
                  user["VKID"] = "\(userID)"
                  user["smallProfileImage"] = smallPhoto
                  user["bigProfileImage"] = bigPhoto
                  user["VKAccessToken"] = VKSdk.accessToken().accessToken
                  user.signUpInBackground().continueWithBlock({
                    (task: BFTask!) -> AnyObject! in
                    if task.error == nil {
                      mainTask.setResult(nil)
                    } else {
                      switch task.error!.code {
                      case 202:   // parse: "username is already taken"
                        CurrentUser.sharedCurrentUser().register("\(userID)", AndUser: user)
                      default: break
                      }
                    }
                    return nil
                  })
                  
                }
                
                return nil
              })
              
            } else {
              // Linking VK Account
              PFUser.currentUser()?["VKID"] = "\(userID)"
              PFUser.currentUser()?["VKAccessToken"] = VKSdk.accessToken().accessToken
              PFUser.currentUser()?.saveInBackground().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
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

  
}



// ======================================================= //
// MARK: - VKSdkDelegate
// ======================================================= //
extension VKSDKHandler: VKSdkDelegate {

  public func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
    if result.error == nil {
      didFinishVKAuthentication().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        NSNotificationCenter.defaultCenter().postNotificationName(VKSDK_ACCESS_AUTHORIZATION_SUCCEEDED, object: nil)
        return nil
      }
    } else {
      // auth failed
    }
  }
  
  @objc public func vkSdkUserAuthorizationFailed() {
    VKSdk.authorize(VKSDK_AUTH_PERMISSIONS)
  }
  

  
}



// ======================================================= //
// MARK: - VKSdkUIDelegate
// ======================================================= //

extension VKSDKHandler: VKSdkUIDelegate {
  
  public func vkSdkDidDismissViewController(controller: UIViewController!, hadBeenCancelled: Bool) {
    if !hadBeenCancelled {
      NSNotificationCenter.defaultCenter().postNotificationName(VKSDK_ACCESS_AUTHORIZATION_STARTED, object: nil)
    }
  }

  public func vkSdkShouldPresentViewController(controller: UIViewController!) {
    let currentVC = UIViewController.currentViewController()
    currentVC.presentViewController(controller, animated: true, completion: nil)
  }

  public func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
    let captchaVC = VKCaptchaViewController.captchaControllerWithError(captchaError)
    let currentVC = UIViewController.currentViewController()
    currentVC.presentViewController(captchaVC, animated: true, completion: nil)
  }

}






