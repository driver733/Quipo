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

  public struct Post {
    
    private var dateFormat = NSDateFormatter()
    
    static var sharedInstance = Post()
    /// Post singleton
    
    
    var pfObject = PFObject(className: "Post")
    
    var userName: String?
    /// The username of the user that created the post
    var timeSincePosted: String?
    /// Time since the creating of the post. "5 minutes ago", "yesterday at 15:45" ...
    var profileImageURL: String?
    /// The URL of the user`s (that created the post) current profile image
    
    
    var trackID: Int?
    /// iTunes track ID
    
    var movieTitle: String?
    /// The title of the movie that the post is dedicated to
    var localizedMovieTitle: String?
    /// The localized title of the movie that the post is dedicated to
    var movieGenre: String?
    /// The genre of the movie that the post is dedicated to
    var movieReleaseDate: String?
    /// The release date of the movie that the post is dedicated to
    var smallPosterImageURL: String?
    /// The small poster image URL of the movie that the post is dedicated to
    var bigPosterImageURL: String?
    /// The big poster image URL of the movie that the post is dedicated to
    
    var feedPosts: [Post] = [Post]()
    /// The array of current user`s feed posts
  
    init() {}
    /// Post singleton initializer
    
    // User post initializer
    init(thePFObject: PFObject, theUserName: String, theTimeSincePosted: String, theProfilImageURL: String, theMovieTitle: String, theLocalizedMovieTitle: String, theMovieGenre: String, theMovieReleaseDate: String, theSmallPosterImageURL: String, theBigPosterImageURL: String) {
      pfObject = thePFObject
      userName = theUserName
      timeSincePosted = theTimeSincePosted
      profileImageURL = theProfilImageURL
      movieTitle = theMovieTitle
      localizedMovieTitle = theLocalizedMovieTitle
      movieGenre = theMovieGenre
      movieReleaseDate = theMovieReleaseDate
      smallPosterImageURL = theSmallPosterImageURL
      bigPosterImageURL = theBigPosterImageURL
    }
    
    // Search result post initializer
    init (theTrackID: Int, theMovieTitle: String, theLocalizedMovieTitle: String, theMovieGenre: String, theMovieReleaseDate: String, theSmallPosterImageURL: String, theBigPosterImageURL: String) {
      trackID = theTrackID
      movieTitle = theMovieTitle
      localizedMovieTitle = theLocalizedMovieTitle
      movieGenre = theMovieGenre
      movieReleaseDate = theMovieReleaseDate
      smallPosterImageURL = theSmallPosterImageURL
      bigPosterImageURL = theBigPosterImageURL
    }
    
    
    
    
    
    
  private func getTimeSincePostedfromDate(datePosted: NSDate) -> String {
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
    
    
    
  private func testColor(theColor: UIColor) -> String {
    
    let color = theColor.CGColor
    let numComponents = CGColorGetNumberOfComponents(color)
    
    if numComponents == 4 {
      let components = CGColorGetComponents(color)
      let red = components[0]
      let green = components[1]
      let blue = components[2]
      
      if red < 0.3 && green < 0.3 && blue < 0.3 {
        return "black"
      } else if red > 0.7 && green > 0.7 && blue > 0.7 {
        return "white"
      } else {
        return "normal"
      }
    }
    return ""
  }

    
    
  func loadFeedPosts() -> BFTask {
      let task = BFTaskCompletionSource()
      let user = PFUser.currentUser()!
      let relation = user.relationForKey("feed")
      let query = relation.query()
      query?.addDescendingOrder("createdAt")
      query?.findObjectsInBackgroundWithBlock({ (result: [AnyObject]?, error: NSError?) -> Void in
        if error == nil, let result = result {
          let posts = result as! [PFObject]
          for post in posts {
            var tempPost = Post()
            tempPost.userName = (post["createdBy"] as! PFUser).username
            tempPost.timeSincePosted = self.getTimeSincePostedfromDate(post.createdAt!)
            tempPost.profileImageURL = (post["createdBy"] as! PFUser)["smallProfileImage"] as? String  // change to user.object for key -profilePicture
            //
            // needs fix!
            //
            self.getMovieInfoByITunesID(post["trackID"] as! Int, completionHandler: { (responseJSON: JSON) -> Void in
              let json = responseJSON["results"][0]
              tempPost.bigPosterImageURL = self.getBigPosterImageURL(json["artworkUrl100"].stringValue)
              Post.sharedInstance.feedPosts.append(tempPost)
            })
          }
          task.setResult(nil)
        } else {
          task.setError(error)
        }
      })
      return task.task
    }
    
    
    func getMovieInfoByTitleAtCountry(movieTitle: String, country: String, completionHandler: ((responseJSON : JSON) -> Void)) {
      ITunesApi.find(Entity.Movie).by(movieTitle).at(country).request({ (responseString: String?, error: NSError?) -> Void in
        if
          //     error == nil,
          let responseString = responseString,
          let dataFromString = responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            return completionHandler(responseJSON: JSON(data: dataFromString))
        } else {
          print(error!.localizedDescription)
        }
      })
      
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
    
  func getBigPosterImageURL(defaultPosterImageURL: String) -> String {
    var str = defaultPosterImageURL
    str.replaceRange(Range<String.Index>(start: str.endIndex.advancedBy(-14), end: str.endIndex.advancedBy(-4)), with: "400x400-75")
    return str
  }
    
  func getMovieInfoByITunesID(iTunesID: Int, completionHandler: ((responseJSON : JSON) -> Void)) {
    ITunesApi.lookup(iTunesID).request({ (responseString: String?, error: NSError?) -> Void in
      if
//        error == nil,
        let responseString = responseString, let dataFromString = responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
        return completionHandler(responseJSON: JSON(data: dataFromString))
      }
    })
  }


  func getReformattedReleaseDate(rawReleaseDate: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm::ssZ"
    let date = dateFormatter.dateFromString(rawReleaseDate)
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Day, .Month, .Year], fromDate: date!)
    return ("\(comp.day) \(dateFormatter.monthSymbols[comp.month-1]), \(comp.year)")
  }
    
    
    
    
    func getPrimaryPosterImageColorAndtextColor(posterImage: UIImage) -> [UIColor] {
      
      var returnColors = [UIColor]()
      let uiColor = posterImage.getColors(CGSizeMake(50, 50)).primaryColor
      
      let newColor = testColor(uiColor)
      
      if newColor != "normal" {
        let backgroundUiColor = posterImage.getColors(CGSizeMake(50, 50)).backgroundColor
        let testBackroundColor = testColor(backgroundUiColor)
        
        if testBackroundColor != "normal" {
        
          if testBackroundColor == "black" {
            returnColors.append(UIColor.whiteColor())
            returnColors.append(backgroundUiColor)
            return returnColors
      
          } else {
            returnColors.append(UIColor.blackColor())
            returnColors.append(backgroundUiColor)
            return returnColors
          }
          
        } else {
          returnColors.append(UIColor.whiteColor())
          returnColors.append(backgroundUiColor)
          return returnColors
        }
      } else {
        returnColors.append(UIColor.whiteColor())
        returnColors.append(uiColor)
        return returnColors
      }
      
      
      
        
     
    }
    
    
    

  
    
    
    
    
    
  }






