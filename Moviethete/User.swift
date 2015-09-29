//
//  User.swift
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

struct User {
  
  
  
  
  var username: String?
  var profileImageURL: String?
  var pfUser: PFUser?
  
  
  init(theUsername: String, theProfileImageURL: String, thePfUser: PFUser) {
    username = theUsername
    profileImageURL = theProfileImageURL
    pfUser = thePfUser
  }
  

  
    
  
  
  
  
  
}