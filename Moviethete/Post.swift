//
//  Post.swift
//  Reviews
//
//  Created by Admin on 02/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit
import Bolts
import Parse
import ITunesSwift
import SwiftyJSON
import Async

  public struct Post {
    
    private var dateFormat = NSDateFormatter()
    /// Post singleton
    static var sharedInstance = Post()
    
    
    
    var pfObject = PFObject(className: "Post")
    /// The username of the user that created the post
    var userName: String?
    /// Time since the creating of the post. "5 minutes ago", "yesterday at 15:45" ...
    var timeSincePosted: String?
    /// The URL of the user`s (that created the post) current profile image
    var profileImageURL: String?
    
    
    /// iTunes track ID
    var trackID: Int?
    
    /// The title of the movie that the post is dedicated to
    var movieTitle: String?
    /// The localized title of the movie that the post is dedicated to
    var localizedMovieTitle: String?
    /// The genre of the movie that the post is dedicated to
    var movieGenre: String?
    /// The release date of the movie that the post is dedicated to
    var movieReleaseDate: String?
    /// The small poster image URL of the movie that the post is dedicated to
    var smallPosterImageURL: String?
    /// The small poster image URL of the movie that the post is dedicated to
    var standardPosterImageURL: String?
    /// The big poster image URL of the movie that the post is dedicated to
    var bigPosterImageURL: String?
    /// The title of the movie review
    var reviewTitle:String?
    /// The text of the movie review
    var review: String?
    /// Numerical represention of the rating (for stars)
    var rating: Int?
    
    
    
    
    
    
    
    var feedPosts: [Post] = [Post]()
    /// The array of current user`s feed posts
    
    
    
    var allUserPosts = [Post]()
    
    
  
    init() {}
    /// Post singleton initializer
    
    // User post initializer
    init(thePFObject: PFObject, theUserName: String, theTimeSincePosted: String, theProfilImageURL: String, theTrackID: Int, theRating: Int, theReviewTitle: String, theReview: String) {
      pfObject = thePFObject
      userName = theUserName
      timeSincePosted = theTimeSincePosted
      profileImageURL = theProfilImageURL
      trackID = theTrackID
      rating = theRating
      reviewTitle = theReviewTitle
      review = theReview
    }
    
    // Search result post initializer
    init (theTrackID: Int, theMovieTitle: String, theLocalizedMovieTitle: String, theMovieGenre: String, theMovieReleaseDate: String, theStandardPosterImageURL: String) {
      trackID = theTrackID
      movieTitle = theMovieTitle
      localizedMovieTitle = theLocalizedMovieTitle
      movieGenre = theMovieGenre
      movieReleaseDate = theMovieReleaseDate
      standardPosterImageURL = theStandardPosterImageURL
    }
    
    
    
    
    
    
  func getTimeSincePostedfromDate(datePosted: NSDate) -> String {
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
    
    
    


    
    
    
    
 
    
    
    
    
    
    
    
    
    
    
    func startLoadingFeedPosts() -> BFTask {
      let mainTask = BFTaskCompletionSource()
      let query = PFUser.currentUser()?.relationForKey("feed").query()
      query?.addDescendingOrder("createdAt")
      ITunes.sharedInstance.startLoadingItunesDataFor(query!) { (posts) -> Void in
        Post.sharedInstance.feedPosts = posts
        mainTask.setResult(nil)
      }
      return mainTask.task
    }
    
    
    
    
    
    func startLoadingAllUserPosts() -> BFTask {
      let mainTask = BFTaskCompletionSource()
      let query = PFUser.currentUser()?.relationForKey("posts").query()
      query?.addDescendingOrder("createdAt")
      ITunes.sharedInstance.startLoadingItunesDataFor(query!) { (posts) -> Void in
        Post.sharedInstance.allUserPosts = posts
        mainTask.setResult(nil)
      }
      return mainTask.task
    }
    
    
    
    
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func loadMovieReviewsForMovie(withTrackID: Int) -> BFTask {
      UserReview.sharedInstance.movieReviewsForSelectedMovie.removeAll(keepCapacity: false)
      
      let mainTask = BFTaskCompletionSource()
      var friendsObjectIDs = [String]()
      for socialNetwork in UserSingelton.sharedInstance.allFriends {
        for friend in socialNetwork {
          if friend.isFollowed == true {
            friendsObjectIDs.append((friend.pfUser?.objectId)!)
          }
        }
      }
      
      friendsObjectIDs.append((PFUser.currentUser()?.objectId)!)
      
      let trackID = withTrackID
      let query = PFQuery(className: "Post")
      query.includeKey("createdBy")
      query.whereKey("createdByObjectId", containedIn: friendsObjectIDs)
    
      query.whereKey("trackID", equalTo: trackID)
      
      query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
        if (error == nil) {
          var reviews = [UserReview]()
          for review in results! {
            let reviewAuthor = review["createdBy"] as! PFUser
            let reviewArray = review["userReview"] as! NSArray
            let tempReview = UserReview(
              theStarRating: reviewArray[0] as! Int,
              theTitle: reviewArray[1] as! String,
              theReview: reviewArray[2] as! String,
              thePfObject: review,
              thePfUser: reviewAuthor,
              theTimeSincePosted: self.getTimeSincePostedfromDate(review.createdAt!)
            )
            reviews.append(tempReview)
          }
          UserReview.sharedInstance.movieReviewsForSelectedMovie = reviews
    
            
          
  
          mainTask.setResult(nil)
        } else {
        mainTask.setError(nil)
        }
      }
      return mainTask.task
    }
    
    
    
    
    
    
    
    
    
        



  func getReformattedReleaseDate(rawReleaseDate: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm::ssZ"
    let date = dateFormatter.dateFromString(rawReleaseDate)
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Day, .Month, .Year], fromDate: date!)
    return ("\(comp.day) \(dateFormatter.monthSymbols[comp.month-1]), \(comp.year)")
  }
    
    
    
        
    
    
    
  }






