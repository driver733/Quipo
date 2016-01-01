//
//  iTunesAPI.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 10/13/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
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


public enum Region: String {
  case UnitedStates = "us"
  case Russia       = "ru"
}


class ITunes {
  
  /// ITunesAPI singleton
  static var sharedInstance = ITunes()
  
  private func processPost(post: Post, json: JSON) -> Post {
    post.bigPosterImageURL = self.bigPosterImageURL(json["artworkUrl100"].stringValue)
    post.standardPosterImageURL = self.standardPosterImageURL(json["artworkUrl100"].stringValue)
    post.movieTitle = json["trackName"].stringValue
    post.releaseDate = self.formattedReleaseDate(json["releaseDate"].stringValue)
    post.releaseYear = self.releaseYear(json["releaseDate"].stringValue)
    post.longDescription = json["longDescription"].stringValue
    return post
  }
  
  func movieInfoByITunesID(iTunesID: Int, post: Post) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    ITunesApi.lookup(iTunesID).request({ (responseString: String?, error: NSError?) -> Void in
      if
        //        error == nil,
        let responseString = responseString, let dataFromString = responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
          let json = JSON(data: dataFromString)["results"][0]
          let processedPost = self.processPost(post, json: json)
          mainTask.setResult(processedPost)
      } else {
        // process error
      }
    })
    return mainTask.task
  }

  func movieInfoByTitleAtCountry(movieTitle: String, country: String, completionHandler: ((searchResults: [Post]) -> Void)) {
    ITunesApi.find(Entity.Movie).by(movieTitle).at(country).request({ (responseString: String?, error: NSError?) -> Void in
      var searchResults = [Post]()
      if
        //     error == nil,
        let responseString = responseString,
        let dataFromString = responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
          let json = JSON(data: dataFromString)
          for (_, subJSON) in json["results"] {
            let foundMovie = Post(
              theTrackID: subJSON["trackId"].numberValue.integerValue,
              theMovieTitle: subJSON["trackName"].stringValue,
              theLocalizedMovieTitle: subJSON["trackName"].stringValue,
              theMovieGenre: subJSON["primaryGenreName"].stringValue,
              theMovieReleaseDate: ITunes.sharedInstance.formattedReleaseDate(subJSON["releaseDate"].stringValue),
              theMovieReleaseYear: ITunes.sharedInstance.releaseYear(subJSON["releaseDate"].stringValue),
              theSmallPosterImageURL: ITunes.sharedInstance.smallPosterImageURL(subJSON["artworkUrl100"].stringValue),
              theStandardPosterImageURL: ITunes.sharedInstance.standardPosterImageURL(subJSON["artworkUrl100"].stringValue),
              theLongDescription: subJSON["longDescription"].stringValue
            )
            searchResults.append(foundMovie)
          }
          completionHandler(searchResults: searchResults)
      } else {
        
      }
    })
  }
  
  func formattedReleaseDate(rawReleaseDate: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm::ssZ"
    let date = dateFormatter.dateFromString(rawReleaseDate)
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Day, .Month, .Year], fromDate: date!)
    return ("\(comp.day) \(dateFormatter.monthSymbols[comp.month-1]), \(comp.year)")
  }
  
  private func releaseYear(rawReleaseDate: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm::ssZ"
    let date = dateFormatter.dateFromString(rawReleaseDate)
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Day, .Month, .Year], fromDate: date!)
    return ("\(comp.year)")
  }
  
  func tinyPosterImageURL(initialPosterImageURL: String) -> String {
    var str = initialPosterImageURL
    str.replaceRange(Range<String.Index>(start: str.endIndex.advancedBy(-13), end: str.endIndex.advancedBy(-4)), with: "50x50-75")
    return str
  }
  
  func smallPosterImageURL(initialPosterImageURL: String) -> String {
    var str = initialPosterImageURL
    str.replaceRange(Range<String.Index>(start: str.endIndex.advancedBy(-13), end: str.endIndex.advancedBy(-4)), with: "200x200-85")
    return str
  }
  
  func standardPosterImageURL(initialPosterImageURL: String) -> String {
    var str = initialPosterImageURL
    str.replaceRange(Range<String.Index>(start: str.endIndex.advancedBy(-13), end: str.endIndex.advancedBy(-4)), with: "400x400-85")
    return str
  }
  
  func bigPosterImageURL(initialPosterImageURL: String) -> String {
    var str = initialPosterImageURL
    str.replaceRange(Range<String.Index>(start: str.endIndex.advancedBy(-13), end: str.endIndex.advancedBy(-4)), with: "600x600-85")
    return str
  }
  
  
}

