//
//  UserReview.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 9/4/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import Foundation
import Parse


public class UserReview {
  
  static var sharedInstance = UserReview()
  
  var pfObject: PFObject!
//  
//  var movieReviewsForSelectedMovie = [UserReview]()
//  var commentsForSelectedReview: [Comment]!
//  var userMediaInfoForSelectedMovie: UserMedia!
  
  
//  lazy var avgMovieRatingForSelectedMovie: Int! = {
//    var ratingsSum: Int = 0
//    for review in self.movieReviewsForSelectedMovie {
//      ratingsSum += review.starRating!
//    }
//    return ratingsSum / self.movieReviewsForSelectedMovie.count
//  }()
  
  
  var pfUser: PFUser?
  /// The star rating representation. Takes Int values from 1 to 5.
  var starRating: Int?
  /// The title of the review
  var title: String?
  /// The review of the movie
  var review: String?
  /// Time since the review was posted
  var timeSincePosted: String?
  /// Comments for the review
  var comments: [Comment]!
  
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
        mainTask.setError(task.error!)
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
        mainTask.setError(task.error!)
        return nil
      }
  }

    return mainTask.task

  }
  
  
  
  func loadComments() -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let commentsQuery = self.pfObject.relationForKey("comments").query()
    commentsQuery.includeKey("createdBy")
    commentsQuery.addAscendingOrder("createdAt")
    commentsQuery.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
      if let results = results where error == nil {
        var comments = [Comment]()
        for commentObj in results {
          let commentAuthor = commentObj["createdBy"] as! PFUser
          let user = User(thePfUser: commentAuthor)
          let createdAt = commentObj.createdAt
          let timeSincePosted = Post.sharedInstance.timeSincePostedfromDate(createdAt!)
          let text = commentObj["text"] as! String
          let comment = Comment(theCreatedBy: user, theTimeSincePosted: timeSincePosted, theText: text, thePfObject: commentObj)
          comments.append(comment)
        }
        self.comments = comments
      }
    })
    return mainTask.task
  }

  
  
  
  
  
}



