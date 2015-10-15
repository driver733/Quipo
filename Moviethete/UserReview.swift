//
//  UserReview.swift
//  Moviethete
//
//  Created by Mike on 9/4/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import Foundation
import Parse


public struct UserReview {
  
  static var sharedInstance = UserReview()
  
  
  var pfObject: PFObject?
  
  var selectedMovieReviews = [UserReview]()
  
  
  var pfUser: PFUser?
  /// The star rating representation. Takes Int values from 1 to 5.
  var starRating: Int?
  /// The title of the review
  var title: String?
   /// The review of the movie
  var review: String?
 
  var timeSincePosted: String?
  
  
  init(){}
  
  
  init(theStarRating: Int, theTitle: String, theReview: String) {
    starRating = theStarRating
    title = theTitle
    review = theReview
  }
  
  
  init(theStarRating: Int, theTitle: String, theReview: String, thePfObject: PFObject, thePfUser: PFUser?, theTimeSincePosted: String) {
    starRating = theStarRating
    title = theTitle
    review = theReview
    pfObject = thePfObject
    pfUser = thePfUser
    timeSincePosted = theTimeSincePosted
  }
  
  
  
  
  
  
  
  
 
  
  
  
  
  func uploadReview(post: Post, rating: Int, reviewTitle: String, review: String) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    
    let parsePost = PFObject(className: "Post")
    parsePost["userReview"] = [rating, reviewTitle, review]
    parsePost["trackID"] = post.trackID!
    parsePost["createdBy"] = PFUser.currentUser()!
    parsePost["createdByObjectId"] = PFUser.currentUser()!.objectId!
    parsePost.saveInBackground().continueWithBlock { (task: BFTask!) -> AnyObject! in
      if task.error == nil {
        let reviewsRelation = PFUser.currentUser()?.relationForKey("posts")
        reviewsRelation?.addObject(parsePost)
        let feedRelation = PFUser.currentUser()?.relationForKey("feed")
        feedRelation?.addObject(parsePost)
        return PFUser.currentUser()?.saveInBackground()
      } else {
        mainTask.setError(task.error)
        return nil
      }
    }.continueWithBlock { (task: BFTask!) -> AnyObject! in
      if task.error == nil {
        PFCloud.callFunctionInBackground("appendNewUserPostToFollowersFeeds",
          withParameters: ["currentUserObjectId" : (PFUser.currentUser()?.objectId)!],
          block: { (result: AnyObject?, error: NSError?) -> Void in
            if error == nil {
              mainTask.setResult(nil)
            }
        })
        return nil
      } else {
        mainTask.setError(task.error)
        return nil
      }
  }

    return mainTask.task

    
  }
  
  
  
  
  
}



