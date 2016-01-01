//
//  DetailedSettingsVC.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 9/7/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
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
//import FontBlaster
import Parse
import ParseFacebookUtilsV4
import SDWebImage
import Async

class LinkedAccountsVC: UIViewController, LoadingStateDelegate {
  
  
  var tableView: UITableView!
  
  var loginActivityIndicator: UIActivityIndicatorView!
  let loginActivityIndicatorBackgroundView = UIView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView = UITableView()
    tableView.dataSource = self
    tableView.delegate = self
    tableView.registerNib(UINib(nibName: "ProfileSettingsFollowFriendsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsFollowFriendsCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    tableView.tableFooterView = UIView(frame: CGRectZero)
    self.view = tableView
    

 //   NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFacebookProfile:", name: FBSDKProfileDidChangeNotification, object: nil)
  //  NSNotificationCenter.defaultCenter().addObserver(self, selector: "instagramLoginWebViewWillDisappear:", name: "instagramLoginWebViewWillDisappear", object: nil)
    
    UserSingleton.getSharedInstance().loginLoadingStateDelegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}


// MARK: - UITableViewDataSource
extension LinkedAccountsVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsFollowFriendsCell", forIndexPath: indexPath) as! ProfileSettingsFollowFriendsCell
    let linkedAccount = LinkedAccount.linkedAccounts[indexPath.row]
    cell.icon.image = UIImage(named: linkedAccount.localIconName!)
    cell.label.text = linkedAccount.serviceName
    cell.account.text = linkedAccount.username
    return cell
  }
    
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return LinkedAccount.linkedAccounts.count
  }

}

// MARK: - UITableViewDelegate
extension LinkedAccountsVC: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let linkedAccount = LinkedAccount.linkedAccounts[indexPath.row]
        if linkedAccount.isLoggedIn {
          let alertController = UIAlertController(title: "Log Out", message: "Log Out from \(linkedAccount.serviceName)?", preferredStyle: UIAlertControllerStyle.Alert)
          let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
          let logOutAction = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
            linkedAccount.logout()
            self.tableView.reloadData()
          })
          alertController.addAction(cancelAction)
          alertController.addAction(logOutAction)
          presentViewController(alertController, animated: true, completion: nil)
          } else {
            linkedAccount.loginTask().continueWithSuccessBlock { (task: BFTask) -> AnyObject? in
            self.tableView.reloadData()
            return nil
          }
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










