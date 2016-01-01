//
//  ProfileSettings.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 8/1/15.
//  Copyright (c) 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
import VK_ios_sdk
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

let DID_SELECT_LINKED_ACCOUNTS_SETTINGS_CELL_SEGUE_IDENTIFIER = "linkedAccounts"
let DID_SELECT_FOLLOW_FRIENDS_SETTINGS_CELL_SEGUE_IDENTIFIER = "followFriends"

class ProfileSettings: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  var loginActivityIndicator: UIActivityIndicatorView!
  let loginActivityIndicatorBackgroundView = UIView()
  
  var loadingStateView: LoadingIndicatorView?
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      tableView.registerNib(UINib(nibName: "ProfileSettingsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsCell")
      tableView.registerNib(UINib(nibName: "ProfileSettingsFollowFriendsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsFollowFriendsCell")
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 44.0
      
      tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
      
 //     NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishLoadingLinkedAccountsData:", name: "didFinishLoadingLinkedAccountsData", object: nil)
      
//      if UserSingleton.getSharedInstance().allFriends.isEmpty {
//        UserSingleton.getSharedInstance().loadLinkedAccountsFriends().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
//          self.tableView.reloadData()
//          return nil
//        }
//      }
      
      UserSingleton.getSharedInstance().followFriendsDelegate = self
    }
  
  

  override func viewWillAppear(animated: Bool) {
    self.title = "Settings"
  }

  
  func startLoginActivityIndicator() {
    loginActivityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 10, 10)) as UIActivityIndicatorView
    loginActivityIndicatorBackgroundView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y - 20, self.view.bounds.width, self.view.bounds.height)
    loginActivityIndicatorBackgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? DetailedSettingsVC {
      vc.cellIndexPath = tableView.indexPathForSelectedRow!
    }
  }
  
  
  
  func logOut() {
    
    PFUser.logOutInBackground()              // causes freeze sometimes ONLY IN SIMULATOR - WORKS FINE ON 8.4 DEVICE
    InstagramEngine.sharedEngine().logout()  // might cause freeze
    VKSdk.forceLogout()
    FBSDKLoginManager().logOut()
    Twitter.sharedInstance().logOut()
    
//    UserSingleton.getSharedInstance().linkedAccountsKeychain["instagram"] = nil
    UserSingleton.getSharedInstance()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let loginVC = (appDelegate.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("login"))!
    loginVC.view.layoutIfNeeded()
    UIView.transitionFromView(
      (appDelegate.window?.rootViewController?.view)!,
      toView: loginVC.view,
      duration: 0.5,
      options: UIViewAnimationOptions.TransitionCrossDissolve,
      completion: { (_) -> Void in
        appDelegate.window!.rootViewController! = loginVC
      })
  }
  
}


// MARK: - UITableViewDelegate
extension ProfileSettings: UITableViewDelegate {
  
  
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 20
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if cell.isKindOfClass(ProfileSettingsFollowFriendsCell) {
      let cell = cell as! ProfileSettingsFollowFriendsCell
      cell.separatorInset.left = cell.label.frame.origin.x
    }
  }
  
  
 
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let view = UITableViewHeaderFooterView()
    let label = UILabel()
    label.frame = CGRectMake(12, -15, 200, 30)
    label.font = label.font.fontWithSize(13)
    label.textColor = UIColor.darkGrayColor()
    view.addSubview(label)

    switch section {
      
    case 0:
      label.text = "Follow friends"
      return view
      
//    case 1:
//      label.text = "Account"
//      return view
      
    case 2:
      label.text = "Settings"
      return view
//      
//    case 3:
//      label.text = "Support"
//      return view
//      
//    case 4:
//      label.text = "About"
//      return view
      
    case 5:
      label.text = ""      // Log Out
      return view
      
      
    default: break
    }
   
    
    return UITableViewHeaderFooterView()
    
  }
  
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    switch indexPath.section {
      
    case 0:
      let vc = DetailedSettingsVC()
      vc.cellIndexPath = indexPath
      self.navigationController?.pushViewController(vc, animated: true)
      
    case 2:
      switch indexPath.row {
      case 0:
        
        self.navigationController?.pushViewController(LinkedAccountsVC(), animated: true)
        
      default: break
      }
      
      
    case 5:
      switch indexPath.row {
      case 0:
        logOut()
        
      default: break
      }
      
      
      
    default:
      break
  }
  
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  
  
}



// MARK: - UITableViewDataSource
extension ProfileSettings: UITableViewDataSource {
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    switch indexPath.section {
      
    case 0:   // follow friends
      
      let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsFollowFriendsCell", forIndexPath: indexPath) as! ProfileSettingsFollowFriendsCell
      cell.icon.image = UIImage(named: UserSingleton.getSharedInstance().followFriendsData[indexPath.row].localIconName!)
      cell.label.text = UserSingleton.getSharedInstance().followFriendsData[indexPath.row].description
      return cell
       
      case 1:
        
        switch indexPath.row {
        
        case 0:
          let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
          cell.setting.text = "Edit Profile"
          return cell
        
        case 1:
          let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
          cell.setting.text = "Change Password"
          return cell
            
        case 2:
          let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
          cell.setting.text = "Liked posts"
          return cell
            
            default: break
          
      }
      
      
    case 2:
      switch indexPath.row {
        
      case 0:
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
        cell.setting.text = "Linked Accounts"
        return cell
        
        
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
        cell.setting.text = "Push Notifications"
        return cell
        
        
      default: break
        
      }
      

      
    case 3:
      switch indexPath.row {
        
      case 0:
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
        cell.setting.text = "Help Center"
        return cell
        
        
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
        cell.setting.text = "Report a Problem"
        return cell
        
        
      default: break
        
      }
      

    case 4:
      switch indexPath.row {
        
      case 0:
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
        cell.setting.text = "Blog"
        return cell
        
        
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
        cell.setting.text = "Privacy Policy"
        return cell
        
        
      case 2:
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
        cell.setting.text = "Open Source Libraries"
        return cell
        
      default: break
        
      }

 
    case 5:  // Log Out and clear search
      switch indexPath.row {
        
      case 0:
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
        cell.setting.text = "Log Out"
        return cell
      
        
        default: break
      }
      
    default: break
    }

      
      return UITableViewCell()
  
  }
  

  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch section {
      
    case 0:
      return UserSingleton.getSharedInstance().followFriendsData.count
      
    case 1:
      //return 3
      return 0
      
    case 2:
     // return 4
      return 1
      
    case 3:
   //   return 2
      return 0
      
    case 4:
//      return 5
      return 0
      
    case 5:
      // return 2
      return 1
      
    default:
      break
    }
    
    
    
    
    
  return 1
  }
  
  
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 6
  }
  
  
  
  
}






extension ProfileSettings: LoadingStateDelegate {
  
  func didStartNetworingActivity() {
    self.view.addSubview(LoadingIndicatorView())
  }
  
  func didEndNetworingActivity() {
    self.view.viewWithTag(LoadingIndicatorViewTag)?.removeFromSuperview()
  }
  
}



extension ProfileSettings: FollowFriendsDelegate {
  func didUpdateFollowFriendsData() {
    tableView.reloadData()
  }
}










