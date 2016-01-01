//
//  Comment.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 11/8/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import Foundation
import Parse


class Comment {
  
   
  init() {}
  
  var createdBy: User!
  var timeSincePosted: String!
  var text: String!
  var pfObject: PFObject!
  
  init(theCreatedBy: User, theTimeSincePosted: String, theText: String, thePfObject: PFObject) {
    createdBy = theCreatedBy
    timeSincePosted = theTimeSincePosted
    text = theText
    pfObject = thePfObject
  }
  
  
  
  init(theCreatedBy: User, theText: String) {
    createdBy = theCreatedBy
    timeSincePosted = "just now"
    text = theText
  }
  
  
  
  func uploadForReviewPFObject(forReviewWithPfObject: PFObject) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let commentObj = PFObject(className: "Comment")
    commentObj["text"] = self.text
    commentObj["createdBy"] = PFUser.currentUser()!
    commentObj.saveInBackground().continueWithBlock { (task: BFTask!) -> AnyObject! in
      if task.error == nil {
        let reviewObj = forReviewWithPfObject
        let relation = reviewObj.relationForKey("comments")
        relation.addObject(commentObj)
        return reviewObj.saveInBackground()
      } else {
        return nil
      }
      }.continueWithBlock { (task: BFTask!) -> AnyObject! in
        if task.error == nil {
          mainTask.setResult(self)
          return nil
        } else {
          return nil
        }
    }
    return mainTask.task
  }
  
  
  
  
    
  
  
}