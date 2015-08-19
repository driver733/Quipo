//
//  ProfileSettings.swift
//  Moviethete
//
//  Created by Mike on 8/1/15.
//  Copyright (c) 2015 Admin. All rights reserved.
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
import FontBlaster
import Parse
import ParseFacebookUtilsV4

class ProfileSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "ProfileSettingsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsCell")
        tableView.registerNib(UINib(nibName: "ProfileSettingsFollowFriendsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsFollowFriendsCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 44.0;
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if FBSDKAccessToken.currentAccessToken() != nil {
        if indexPath.section == 0 {
          let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsFollowFriendsCell", forIndexPath: indexPath) as! ProfileSettingsFollowFriendsCell
            if indexPath.row == 0 {
                    cell.socialNetworkIcon.image = UIImage(named: "facebook")
                    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: nil)
                    graphRequest.startWithCompletionHandler({
                        (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                        if error == nil {
                            let json = JSON(result)
                            var numberOfFacebookFriends: Int = Int()
                            for (index: String, subJson: JSON) in json["data"] {
                                numberOfFacebookFriends++
                            }
                            cell.label.text = "\(numberOfFacebookFriends) Facebook Friends"
                          
                           
                        }
                        else {
                            // process error
                        }
                    })
                }
                return cell
            }
            
      }

        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSettingsCell", forIndexPath: indexPath) as! ProfileSettingsCell
            cell.tempLabel.text = "Log Out"
            return cell
        }
        
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.section == 1 {
            PFUser.logOut()
            InstagramEngine.sharedEngine().logout()
            VKSdk.forceLogout()
            FBSDKLoginManager().logOut()
            Twitter.sharedInstance().logOut()
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            self.presentViewController((appDelegate.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("login"))!, animated: true, completion: nil)
        }
       
        
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        switch section {
        case 0:
            if FBSDKAccessToken.currentAccessToken() != nil {
                numberOfRows++
            }
            if VKSdk.isLoggedIn() {
                numberOfRows++
            }
            break
            
        case 1:
            numberOfRows++
            
        default:
            break
        }
        
        
        
        
        
        return numberOfRows
    }

    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.isKindOfClass(ProfileSettingsFollowFriendsCell) {
           let cell = cell as! ProfileSettingsFollowFriendsCell
           cell.separatorInset.left = cell.label.frame.origin.x
        }
    }
    
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "didLogOut" {
            if let vc = segue.destinationViewController as? LogInVC {
                
            }
        }
        
        
        
        
    }

}
