//
//  FollowFriends.swift
//  Moviethete
//
//  Created by Mike on 9/8/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import Foundation




struct FollowFriends {
  
  
  
  
  var localIconName: String
  var numberOfFriends: Int
  var serviceName: String
  var description: String
  
  
  
  init(theLocalIconName: String, theNumberOfFriends: Int, theServiceName: String) {
    localIconName = theLocalIconName
    numberOfFriends = theNumberOfFriends
    serviceName = theServiceName
    description = String(theNumberOfFriends) + " " + theServiceName + " " + (theNumberOfFriends == 1 ? "friend" : "friends")
  }
  
  
  
  
  
  
  
  
  
}