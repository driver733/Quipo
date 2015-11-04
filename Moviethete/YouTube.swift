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
  
  
  
  func getMovieTrailerWithMovieTitle(movieName: String, releasedIn: String) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/search", parameters: ["key": "AIzaSyDRxPGszcdOWx4BgtzSUhQ0F31_CqT4bXY", "part" : "snippet", "maxResults" : 1, "type" : "video", "videoCategoryId" : "44", "regionCode" : "US", "q" : movieName + " " + releasedIn]).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
    let json = JSON(response.result.value!)
    let trailerId = json["items"][0]["id"]["videoId"].stringValue
    mainTask.setResult("\(trailerId)")
    }
    return mainTask.task
  }
  
  
}