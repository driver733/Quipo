//
//  iTunesAPI.swift
//  Moviethete
//
//  Created by Mike on 10/13/15.
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
//import FontBlaster
import Parse
import ParseFacebookUtilsV4
import ITunesSwift
import Async


struct ITunes {
  
  
  /// ITunesAPI singleton
  static var sharedInstance = ITunes()
  
  
  
  
  
  
  
  func startLoadingItunesDataFor(postsQuery: PFQuery, completionHandler: ((posts: [Post]) -> Void)) {
    postsQuery.includeKey("createdBy")
    
    var newPosts = [Post]()
    
    postsQuery.findObjectsInBackground().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
      var tasks = [BFTask]()
    
      
      if let result = task.result {
        let posts = result as! [PFObject]
        
        for post in posts {
          let postReview = post["userReview"] as! NSArray
          let postAuthor = post["createdBy"] as! PFUser
          
          let tempPost = Post(
            thePFObject: post,
            theUserName: postAuthor.username!,
            theTimeSincePosted: Post.sharedInstance.getTimeSincePostedfromDate(post.createdAt!),
            theProfilImageURL: postAuthor["smallProfileImage"] as! String,
            theTrackID: post["trackID"] as! Int,
            theRating: postReview[0] as! Int,
            theReviewTitle: postReview[1] as! String,
            theReview: postReview[2] as! String
          )
          newPosts.append(tempPost)
          tasks.append(self.getMovieInfoByITunesID(post["trackID"] as! Int))
        }
        
      }
      

      return BFTask(forCompletionOfAllTasksWithResults: tasks)
    }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
      
      let results = task.result as! NSArray
      
      for (index, postData) in results.enumerate() {
        let json = JSON(data: postData as! NSData)
        newPosts[index].bigPosterImageURL = self.getBigPosterImageURL(json["artworkUrl100"].stringValue)
        newPosts[index].standardPosterImageURL = self.getStandardPosterImageURL(json["artworkUrl100"].stringValue)
        newPosts[index].movieTitle = json["trackName"].stringValue
        newPosts[index].releaseDate = self.getReformattedReleaseDate(json["releaseDate"].stringValue)
        newPosts[index].releaseYear = self.getReleaseYear(json["releaseDate"].stringValue)
      }
      
      completionHandler(posts: newPosts)
      
      return nil
    })
    
  }
  
  
  
  

  
  
  
  
  func getMovieInfoByITunesID(iTunesID: Int) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    ITunesApi.lookup(iTunesID).request({ (responseString: String?, error: NSError?) -> Void in
      if
        //        error == nil,
        let responseString = responseString, let dataFromString = responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
          let json = JSON(data: dataFromString)
          
          do {
            try mainTask.setResult(json["results"][0].rawData())
          }
          catch {
            
          }
          
          //  task.setResult(json["results"].arrayObject)
      } else {
        // process error
      }
    })
    return mainTask.task
  }
  
  
  
  
  
  
  
  
  
  func getMovieInfoByTitleAtCountry(movieTitle: String, country: String) -> BFTask {
    let task = BFTaskCompletionSource()
    ITunesApi.find(Entity.Movie).by(movieTitle).at(country).request({ (responseString: String?, error: NSError?) -> Void in
      if
        //     error == nil,
        let responseString = responseString,
        let dataFromString = responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
          let json = JSON(data: dataFromString)
          do {
            try  task.setResult(json["results"].rawData())
          }
          catch {
            
          }
      } else {
        task.setError(error)
        
      }
    })
    return task.task
  }
  
  
  
  
  
   func getReformattedReleaseDate(rawReleaseDate: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm::ssZ"
    let date = dateFormatter.dateFromString(rawReleaseDate)
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Day, .Month, .Year], fromDate: date!)
    return ("\(comp.day) \(dateFormatter.monthSymbols[comp.month-1]), \(comp.year)")
  }
  
  private func getReleaseYear(rawReleaseDate: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm::ssZ"
    let date = dateFormatter.dateFromString(rawReleaseDate)
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Day, .Month, .Year], fromDate: date!)
    return ("\(comp.year)")
  }
  
  
  
  
  
  func getTinyPosterImageURL(defaultPosterImageURL: String) -> String {
    var str = defaultPosterImageURL
    str.replaceRange(Range<String.Index>(start: str.endIndex.advancedBy(-14), end: str.endIndex.advancedBy(-4)), with: "50x50-75")
    return str
  }
  
  func getSmallPosterImageURL(defaultPosterImageURL: String) -> String {
    var str = defaultPosterImageURL
    str.replaceRange(Range<String.Index>(start: str.endIndex.advancedBy(-14), end: str.endIndex.advancedBy(-4)), with: "400x400-75")
    return str
  }
  
  func getStandardPosterImageURL(defaultPosterImageURL: String) -> String {
    var str = defaultPosterImageURL
    str.replaceRange(Range<String.Index>(start: str.endIndex.advancedBy(-14), end: str.endIndex.advancedBy(-4)), with: "400x400-75")
    return str
  }
  
  func getBigPosterImageURL(defaultPosterImageURL: String) -> String {
    var str = defaultPosterImageURL
    str.replaceRange(Range<String.Index>(start: str.endIndex.advancedBy(-14), end: str.endIndex.advancedBy(-4)), with: "600x600-85")
    return str
  }

  
  
  
  
  
  
  
  
  
  
  
}