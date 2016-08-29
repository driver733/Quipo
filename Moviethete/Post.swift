//
//  Post.swift
//  Reviews
//
//  Created by Mikhail Yakushin on 02/07/15.
//  Copyright (c) 2015 Mikhail Yakushin. All rights reserved.
//

import Foundation
import UIKit
import Bolts
import Parse
//import ITunesSwift
import SwiftyJSON
import Async


 enum postsType: String {
  case feed
  case user = "posts"
  case watched
  case watchlist
  case favorite
}


class Post {
  
  private var dateFormat = NSDateFormatter()
  
  /// Post singleton
  static var sharedInstance = Post()
  
  var pfObject = PFObject(className: "Post")
  /// The username of the user that created the post
  var userName: String?
  /// Time since the creating of the post. "5 minutes ago", "yesterday at 15:45" ...
  var timeSincePosted: String?
  /// The author of the post
  var author: User?
  
  /// iTunes track ID
  var trackID: Int?
  
  /// The title of the movie that the post is dedicated to
  var movieTitle: String?
  /// The localized title of the movie that the post is dedicated to
  var localizedMovieTitle: String?
  /// The genre of the movie that the post is dedicated to
  var movieGenre: String?
  /// The release date of the movie that the post is dedicated to
  var releaseDate: String?
  /// The release year
  var releaseYear: String?
  /// The small poster image URL of the movie that the post is dedicated to
  var smallPosterImageURL: String?
  /// The small poster image URL of the movie that the post is dedicated to
  var standardPosterImageURL: String?
  /// The big poster image URL of the movie that the post is dedicated to
  var bigPosterImageURL: String?
  /// Long description
  var longDescription: String?

  // Rotten Tomatoes and IMDB info and ratings
  var OMDB: Movie?
  
  /// The text of the movie review
  var review: String?
  /// The title of the movie review
  var reviewTitle:String?
  /// Numerical represention of the rating (for stars)
  var rating: Int?
  
  
  var comments: [Comment]!
  /**
   Post singleton initializer
   
   - returns: Post singleton
   */
  init() {}
  
  // User post initializer
  init(thePFObject: PFObject, theUserName: String, theTimeSincePosted: String, theUser: User, theTrackID: Int, theRating: Int, theReviewTitle: String, theReview: String) {
    pfObject = thePFObject
    userName = theUserName
    timeSincePosted = theTimeSincePosted
    author = theUser
    trackID = theTrackID
    rating = theRating
    reviewTitle = theReviewTitle
    review = theReview
  }
  
  // Search result post initializer
  init (theTrackID: Int, theMovieTitle: String, theLocalizedMovieTitle: String, theMovieGenre: String, theMovieReleaseDate: String, theMovieReleaseYear: String, theSmallPosterImageURL: String, theStandardPosterImageURL: String, theLongDescription: String) {
    trackID = theTrackID
    movieTitle = theMovieTitle
    localizedMovieTitle = theLocalizedMovieTitle
    movieGenre = theMovieGenre
    releaseDate = theMovieReleaseDate
    releaseYear = theMovieReleaseYear
    smallPosterImageURL = theSmallPosterImageURL
    standardPosterImageURL = theStandardPosterImageURL
    longDescription = theLongDescription
  }

  // ======================================================= //
  // MARK: - Loading
  // ======================================================= //
  
  func loadPosts(pfUser: PFUser, reqType: postsType) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let query = pfUser.relationForKey(reqType.rawValue).query()
    query.addDescendingOrder("createdAt")
    query.includeKey("createdBy")
    loadPosts(query)
    .continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
      if let posts = task.result as? [Post] {
        var tasks = [BFTask]()
        for post in posts {
          tasks.append(ITunes.sharedInstance.movieInfoByITunesID(post.trackID!, post: post))
        }
        return BFTask(forCompletionOfAllTasksWithResults: tasks)
      } else {
        return nil
      }
    })
    .continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
      if let posts = task.result as? [Post] {
        var tasks = [BFTask]()
        for post in posts {
          tasks.append(OMDBAPI().advancedSearchByTitle(post, title: post.movieTitle!, type: .Movie, year: Int(post.releaseYear!), fullPlot: false, tomatoes: true))
        }
        return BFTask(forCompletionOfAllTasksWithResults: tasks)
      } else {
        return nil
      }
    })
    .continueWithBlock({ (task: BFTask!) -> AnyObject! in
      if let posts = task.result as? [Post] where task.error == nil {
        mainTask.setResult(posts)
      } else if let error = task.error {
        mainTask.setError(error)
      }
      return nil
    })
      return mainTask.task
  }
    
  private func loadPosts(forQuery: PFQuery) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    var newPosts = [Post]()
    forQuery.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) -> Void in
    if let posts = result {
      for post in posts {
        let postReview = post["userReview"] as! NSArray
        let pfPostAuthor = post["createdBy"] as! PFUser
        let postAuthor = User(thePfUser: pfPostAuthor)
        let tempPost = Post(
          thePFObject: post,
          theUserName: postAuthor.username!,
          theTimeSincePosted: Post.sharedInstance.timeSincePostedfromDate(post.createdAt!),
          theUser: postAuthor,
          theTrackID: post["trackID"] as! Int,
          theRating: postReview[0] as! Int,
          theReviewTitle: postReview[1] as! String,
          theReview: postReview[2] as! String
        )
        newPosts.append(tempPost)
      }
    }
      mainTask.setResult(newPosts)
    }
      return mainTask.task
    }
    
  func loadMovieReviewsForMovie(withTrackID: Int) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    var friendsObjectIDs = [String]()
    friendsObjectIDs.append(CurrentUser.sharedCurrentUser().pfUser.objectId!)
    for followedUser in CurrentUser.sharedCurrentUser().following {
      friendsObjectIDs.append(followedUser.pfUser.objectId!)
    }
    let trackID = withTrackID
    let query = PFQuery(className: "Post")
    query.includeKey("createdBy")
    query.whereKey("createdByObjectId", containedIn: friendsObjectIDs)
    query.whereKey("trackID", equalTo: trackID)
    query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
      if let results = results where error == nil {
        var reviews = [UserReview]()
        for review in results {
          let reviewAuthor = review["createdBy"] as! PFUser
          let reviewArray = review["userReview"] as! NSArray
          let tempReview = UserReview(
            theStarRating: reviewArray[0] as! Int,
            theTitle: reviewArray[1] as! String,
            theReview: reviewArray[2] as! String,
            thePfObject: review,
            thePfUser: reviewAuthor,
            theTimeSincePosted: self.timeSincePostedfromDate(review.createdAt!)
          )
          reviews.append(tempReview)
        }
        mainTask.setResult(reviews)
      } else {
 //     mainTask.setError(nil)
      }
    }
    return mainTask.task
  }
  
  // ======================================================= //
  // MARK: - Convinience
  // ======================================================= //

  func timeSincePostedfromDate(datePosted: NSDate) -> String {
    dateFormat.dateFormat = "EEE, MMM d, h:mm a"
    let ti = NSDate().timeIntervalSinceDate(datePosted)
    if ti < 2 {
      return "1 second ago"
    } else if ti < 60 {
      return "\(Int(ti)) seconds ago"
    } else if ti == 60 {
      return "1 minute ago"
    } else if ti < 3600 {
      return "\(Int(ti) / 60) minutes ago"
    } else if ti == 3600 {
      return "1 hour ago"
    } else if ti <= 3600 * 3 {
      return "\(Int(ti) / 60 / 60) hours ago"
    } else if ti < 3600 * 24 {                                                                                // today
      let comp = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: datePosted)
      return "today at \(comp.hour):\(comp.minute)"
    } else if ti < 3600 * 24 * 2 {                                                                            // yesterday
      let comp = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: datePosted)
      return "yesterday at \(comp.hour):\(comp.minute)"
    } else {                                                                                                  // specific time and date
      let comp = NSCalendar.currentCalendar().components([.Month, .Day, .Hour, .Minute], fromDate: datePosted)
      return "\(dateFormat.monthSymbols[comp.month - 1]) \(comp.day) at \(comp.hour):\(comp.minute)"
    }
  }
    
    
    
  }






