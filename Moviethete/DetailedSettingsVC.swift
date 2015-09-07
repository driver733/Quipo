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

class DetailedSettingsVC: UIViewController {

  @IBOutlet var tableView: UITableView!
  
  var contentTypeTag = Int()
  
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      tableView.registerNib(UINib(nibName: "ProfileSettingsCell", bundle: nil), forCellReuseIdentifier: "ProfileSettingsCell")
      tableView.registerNib(UINib(nibName: "ProfileFollowerCell", bundle: nil), forCellReuseIdentifier: "ProfileFollowerCell")
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
    

  

}

extension DetailedSettingsVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    switch contentTypeTag {
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
      let user = UserSingelton.sharedInstance.facebookFriends[indexPath.row]
      cell.userName.text = user.username
      cell.profileImage.sd_setImageWithURL(
        NSURL(string: user.profileImageURL!),
        placeholderImage: getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.bounds.size),
        options: SDWebImageOptions.RefreshCached,
        completed:{
          (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
          cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
        }
      )
      
      return cell
      
      
    default: break
    }
    
    return UITableViewCell()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  
}






extension DetailedSettingsVC: UITableViewDelegate {
  
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if cell.isKindOfClass(ProfileFollowerCell) {
      let cell = cell as! ProfileFollowerCell
      cell.separatorInset.left = cell.userName.frame.origin.x
    }
  }
  
  
  
  
}


