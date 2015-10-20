//
//  DetailedSettingsVC.swift
//  Moviethete
//
//  Created by Mike on 9/7/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

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
import SDWebImage
import Async

class LinkedAccountsVC: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  
  var loginActivityIndicator: UIActivityIndicatorView!
  let loginActivityIndicatorBackgroundView = UIView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    tableView.registerNib(UINib(nibName: "ProfileSettingsFollowFriendsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsFollowFriendsCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    
    FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFacebookProfile:", name: FBSDKProfileDidChangeNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "instagramLoginWebViewWillDisappear:", name: "instagramLoginWebViewWillDisappear", object: nil)
   
  }
  
  

  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  override func viewWillAppear(animated: Bool) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFacebookProfile:", name: FBSDKProfileDidChangeNotification, object: nil)
  }
  

  
  func instagramLoginWebViewWillDisappear(notif: NSNotification) {
    startLoginActivityIndicator()
  }
  
  func didReceiveFacebookProfile(notif: NSNotification) {
    startLoginActivityIndicator()
    NSNotificationCenter.defaultCenter().removeObserver(self, name: FBSDKProfileDidChangeNotification, object: nil)
    UserSingelton.sharedInstance.didReceiveFacebookProfile().continueWithBlock { (task: BFTask!) -> AnyObject! in
      Async.main {
        self.tableView.reloadData()
        self.stopLoginActivityIndicator()
      }
      return nil
      }  
  }
  
  
  func startLoginActivityIndicator() {
    loginActivityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 10, 10)) as UIActivityIndicatorView
    loginActivityIndicatorBackgroundView.frame = self.view.frame
    loginActivityIndicatorBackgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    loginActivityIndicatorBackgroundView.center = self.view.center
    loginActivityIndicator.center = self.view.center
    loginActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    loginActivityIndicatorBackgroundView.addSubview(loginActivityIndicator)
    self.view.addSubview(loginActivityIndicatorBackgroundView)
    loginActivityIndicator.startAnimating()
    tableView.userInteractionEnabled = false
  }
  
  func stopLoginActivityIndicator() {
    if loginActivityIndicator != nil {
      loginActivityIndicator.stopAnimating()
      loginActivityIndicator.removeFromSuperview()
      loginActivityIndicatorBackgroundView.removeFromSuperview()
      tableView.userInteractionEnabled = true
    }
  }

  
  
  
}


// MARK: - UITableViewDataSource
extension LinkedAccountsVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsFollowFriendsCell", forIndexPath: indexPath) as! ProfileSettingsFollowFriendsCell
        let linkedAccount = FollowFriends.sharedInstance.linkedAccounts[indexPath.row]
        cell.icon.image = UIImage(named: linkedAccount.localIconName!)
        cell.label.text = linkedAccount.serviceName
        cell.account.text = linkedAccount.username
        
        return cell
    
  }
  
  
  
  
  
  
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//  print(FollowFriends.sharedInstance.linkedAccounts.count)
  return FollowFriends.sharedInstance.linkedAccounts.count
}



}

// MARK: - UITableViewDelegate
extension LinkedAccountsVC: UITableViewDelegate {
  
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    switch indexPath.row {
      
    case 0:
      if FBSDKAccessToken.currentAccessToken() == nil {
        UserSingelton.sharedInstance.loginWithFacebook(self)
      } else {
        let alertController = UIAlertController(title: "Log Out", message: "Logout from Facebook", preferredStyle: UIAlertControllerStyle.Alert)
        let logOutAction = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
          self.startLoginActivityIndicator()
          UserSingelton.sharedInstance.logoutFromFacebook().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            Async.main {
              tableView.reloadData()
              self.stopLoginActivityIndicator()
            }
            return nil
          })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(logOutAction)
        presentViewController(alertController, animated: true, completion: nil)
      }
    
    case 1:
      if InstagramEngine.sharedEngine().accessToken == nil {
        UserSingelton.sharedInstance.loginWithInstagram().continueWithSuccessBlock({ (task:BFTask!) -> AnyObject! in
          Async.main {
            self.tableView.reloadData()
            self.stopLoginActivityIndicator()
          }
          return nil
        })
      } else {
        let alertController = UIAlertController(title: "Log Out", message: "Logout from Instagram?", preferredStyle: UIAlertControllerStyle.Alert)
        let logOutAction = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
          self.startLoginActivityIndicator()
          UserSingelton.sharedInstance.logoutFromInstagram().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            Async.main {
              tableView.reloadData()
              self.stopLoginActivityIndicator()
            }
            return nil
          })
          
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(logOutAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    case 2:
      if !VKSdk.isLoggedIn() {
        VKSdk.initializeWithDelegate(self, andAppId: "4991711")
        VKSdk.authorize(["friends", "profile_info", "offline", "wall"])
      } else {
        let alertController = UIAlertController(title: "Log Out", message: "Logout from VKontakte?", preferredStyle: UIAlertControllerStyle.Alert)
        let logOutAction = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
          self.startLoginActivityIndicator()
          UserSingelton.sharedInstance.logoutFromVkontakte().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            Async.main {
              tableView.reloadData()
              self.stopLoginActivityIndicator()
            }
            return nil
          })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(logOutAction)
        presentViewController(alertController, animated: true, completion: nil)
      }
      
 
      
      
      
      
      
      
    default: break
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if cell.isKindOfClass(ProfileFollowerCell) {
      let cell = cell as! ProfileFollowerCell
      cell.separatorInset.left = cell.userName.frame.origin.x
    }
  }
  
}


// MARK: - VKSdkDelegate
extension LinkedAccountsVC: VKSdkDelegate {
  
  func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
    startLoginActivityIndicator()
    UserSingelton.sharedInstance.didReceiveNewVKToken().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      self.tableView.reloadData()
      self.stopLoginActivityIndicator()
      return nil
    }
  }
  
  
  
  func vkSdkIsBasicAuthorization() -> Bool {
    return false
  }
  
  func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
    VKSdk.getAccessToken()
  }
  
  func vkSdkUserDeniedAccess(authorizationError: VKError!) {
    
  }
  
  func vkSdkShouldPresentViewController(controller: UIViewController!) {
    self.presentViewController(controller, animated: true, completion: nil)
  }
  
  func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
    let vc = VKCaptchaViewController.captchaControllerWithError(captchaError)
    self.presentViewController(vc, animated: true, completion: nil)
  }
  
}





