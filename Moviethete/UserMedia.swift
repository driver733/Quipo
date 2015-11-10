//
//  UserMedia.swift
//  Moviethete
//
//  Created by Mike on 11/9/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import Foundation
import Parse


struct UserMedia {
  
  static var sharedInstance = UserMedia()
  

  var isWatched = false
  var isStarred = false
  var pfObject: PFObject?
  
  init(){}
  
  init(theIsWatched: Bool, theIsStarred: Bool) {
    isWatched = theIsWatched
    isStarred = theIsStarred
  }
  
  init(theIsWatched: Bool, theIsStarred: Bool, thePfObject: PFObject) {
    isWatched = theIsWatched
    isStarred = theIsStarred
    pfObject = thePfObject
  }
  
  
  func markMovie(withTrackID: Int, AsWatched: Bool, pfObject: PFObject?) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    var obj: PFObject!
    if let pfObject = pfObject {
      obj = pfObject
    } else {
      obj = PFObject(className: "UserMedia")
    }
    obj["trackID"] = withTrackID
    obj["isWatched"] = NSNumber(bool: AsWatched)
    obj["by"] = PFUser.currentUser()!
    obj.saveInBackgroundWithBlock { (result: Bool, error: NSError?) -> Void in
      if result && error == nil {
        UserReview.sharedInstance.userMediaInfoForSelectedMovie.pfObject = obj
        UserReview.sharedInstance.userMediaInfoForSelectedMovie.isWatched = AsWatched
        mainTask.setResult(nil)
      }
    }
    return mainTask.task
  }
  
  
  func markMovie(withTrackID: Int, AsStarred: Bool, pfObject: PFObject?) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    var obj: PFObject!
    if let pfObject = pfObject {
      obj = pfObject
    } else {
      obj = PFObject(className: "UserMedia")
    }
    obj["trackID"] = withTrackID
    obj["isStarred"] = NSNumber(bool: AsStarred)
    obj["by"] = PFUser.currentUser()!
    obj.saveInBackgroundWithBlock { (result: Bool, error: NSError?) -> Void in
      if result && error == nil {
        UserReview.sharedInstance.userMediaInfoForSelectedMovie.pfObject = obj
        UserReview.sharedInstance.userMediaInfoForSelectedMovie.isStarred = AsStarred
        mainTask.setResult(nil)
      }
    }
    return mainTask.task
  }
  
  
  
  func startLoadingUserMediaInfoForMovie(withTrackID: Int, andUser: PFUser) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let query = PFQuery(className: "UserMedia")
    query.whereKey("by", equalTo: PFUser.currentUser()!)
    query.whereKey("trackID", equalTo: withTrackID)
    query.limit = 1
    query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
      if let results = results where error == nil {
        if results.count == 1 {
          var IsWatched = false
          if let watched = (results[0])["isWatched"] {
              IsWatched = watched.boolValue
          }
          var IsStarred = false
          if let starred = (results[0])["isStarred"] {
            IsStarred = starred.boolValue
          }
          let userMedia = UserMedia(theIsWatched: IsWatched, theIsStarred: IsStarred, thePfObject: results[0])
          UserReview.sharedInstance.userMediaInfoForSelectedMovie = userMedia
          mainTask.setResult(nil)
        } else {
          UserReview.sharedInstance.userMediaInfoForSelectedMovie = UserMedia(theIsWatched: false, theIsStarred: false)
          mainTask.setResult(nil)
        }
      } else {
        UserReview.sharedInstance.userMediaInfoForSelectedMovie = UserMedia(theIsWatched: false, theIsStarred: false)
        mainTask.setResult(nil)
      }
    }
    return mainTask.task
  }
  
  
  
  
}