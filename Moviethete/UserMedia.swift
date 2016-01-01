//
//  UserMedia.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 11/9/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import Foundation
import Parse


class UserMedia {

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
        self.pfObject = obj
        self.isWatched = AsWatched
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
        self.pfObject = obj
        self.isStarred = AsStarred
        mainTask.setResult(nil)
      }
    }
    return mainTask.task
  }
  
  
  /**
   Asyncronously initilizes UserMedia instance based on the provided trackID
   
   - parameter trackID: iTunes trackID of the movie
   
   - returns: BFTask with the resulting UserMedia instance set as the result of the task
   */
  class func userMediaInfoForMovieWithTrackID(trackID: Int) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let query = PFQuery(className: "UserMedia")
    query.whereKey("by", equalTo: UserSingleton.getSharedInstance().pfUser)
    query.whereKey("trackID", equalTo: trackID)
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
          mainTask.setResult(userMedia)
        } else {
          let userMedia = UserMedia(theIsWatched: false, theIsStarred: false)
          mainTask.setResult(userMedia)
        }
      } else {
        let userMedia = UserMedia(theIsWatched: false, theIsStarred: false)
        mainTask.setResult(userMedia)
      }
    }
    return mainTask.task
  }
  
  
  
  
}