//
//  Comment.swift
//  Moviethete
//
//  Created by Mike on 11/8/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import Foundation
import Parse


struct Comment {
  
  static var sharedInstance = Comment()
  
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
  
  
  
  
  
  
  
  func uploadComment(comment: Comment, forReviewWithPfObject: PFObject) {
    let commentObj = PFObject(className: "Comment")
    commentObj["text"] = comment.text
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
          return nil
        } else {
          return nil
        }
    }
    
  }
  
  
  
  
  func startLoadingCommentsForReview(reviewPfObject: PFObject, completionHandler: (() -> Void)) {
    let commentsQuery = reviewPfObject.relationForKey("comments").query()!
    commentsQuery.includeKey("createdBy")
    commentsQuery.addAscendingOrder("createdAt")
    commentsQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
  
      if let results = results where error == nil {
        var comments = [Comment]()
        
        for commentObj in results {
          let commentAuthor = commentObj["createdBy"] as! PFUser
          let user = User(theUsername: commentAuthor.username!, theProfileImageURL: commentAuthor["smallProfileImage"] as! String, thePfUser: commentAuthor)
          let createdAt = commentObj.createdAt
          let timeSincePosted = Post.sharedInstance.getTimeSincePostedfromDate(createdAt!)
          let text = commentObj["text"] as! String
          let comment = Comment(theCreatedBy: user, theTimeSincePosted: timeSincePosted, theText: text, thePfObject: commentObj)
          
          comments.append(comment)
        }
        UserReview.sharedInstance.commentsForSelectedReview = comments
        completionHandler()
      }

    })
  }
  
  
  
}