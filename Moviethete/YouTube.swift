//
//  YouTube.swift
//  Moviethete
//
//  Created by Mike on 11/4/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import Foundation
import SwiftyJSON
import Bolts
import Alamofire


struct YouTube {
  static var sharedInstance = YouTube()
  
  var currentTrailerId: String!
  var currentThumbnailURL: String!
  var currenVideoDuration: String!
  
  
  
 private func getReformattedVideoDuration(rawVideoDuration: String) -> String {
    let dateFormatter = NSDateFormatter()
    if rawVideoDuration.characters.contains("M") {
      dateFormatter.dateFormat = "'PT'm'M'ss'S'"
      let date = dateFormatter.dateFromString(rawVideoDuration)
      let calendar = NSCalendar.currentCalendar()
      let comp = calendar.components([.Minute, .Second], fromDate: date!)
      return ("\(comp.minute):\(comp.second)")
    } else {
      dateFormatter.dateFormat = "'PT'ss'S'"
      let date = dateFormatter.dateFromString(rawVideoDuration)
      let calendar = NSCalendar.currentCalendar()
      let comp = calendar.components([.Second], fromDate: date!)
      return ("0:\(comp.second)")
    }
  }
  
  
  func getMovieTrailerWithMovieTitle(movieName: String, releasedIn: String) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/search", parameters: [
      "key": "AIzaSyDRxPGszcdOWx4BgtzSUhQ0F31_CqT4bXY",
      "part" : "snippet",
      "maxResults" : 1,
      "type" : "video",
  //    "videoCategoryId" : "44",    // 44 - restricts search results to trailers only
      "regionCode" : "US",
      "q" : movieName + " " + releasedIn + "trailer"
      ]
      ).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
      let json = JSON(response.result.value!)           // crash
      let trailerId = json["items"][0]["id"]["videoId"].stringValue
      let thumbnailURL = json["items"][0]["snippet"]["thumbnails"]["default"]["url"].stringValue
      
      Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/videos", parameters: [
        "key": "AIzaSyDRxPGszcdOWx4BgtzSUhQ0F31_CqT4bXY",
        "part" : "contentDetails",
        "maxResults" : 1,
        "type" : "video",
        "videoCategoryId" : "44",
        "regionCode" : "US",
        "id" : trailerId
        ]
        ).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
         let contentDetailsJSON = JSON(response.result.value!)
         let videoDuration = contentDetailsJSON["items"][0]["contentDetails"]["duration"].stringValue
         let reformattedVideoDuration = self.getReformattedVideoDuration(videoDuration)
         mainTask.setResult([trailerId, thumbnailURL, reformattedVideoDuration])
      }
      
      

    }
    return mainTask.task
  }
  
  
}