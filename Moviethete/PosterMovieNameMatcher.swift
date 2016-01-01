//
//  PosterMovieNameMatcher.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 11/23/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import Foundation
import Bolts
import Alamofire
import SwiftyJSON
import Async

class PosterMovieNameMatcher {
  
  class func movieNameOfPoster(withPosterImage: UIImage) -> BFTask {
    let mainTask = BFTaskCompletionSource()
    let image = withPosterImage
    BFTask(forCompletionOfAllTasksWithResults: [uploadImageToImgur(image), userCountryCode()]).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      let results = task.result as! NSArray
      let posterImageURL = results[0] as! String
      let locatedCountryCode = results[1] as! String
      return self.findMovieFor(posterImageURL, inRegionWithRegionCode: locatedCountryCode)
      }.continueWithBlock { (task: BFTask!) -> AnyObject! in
        if task.error == nil {
          let matchedMovieName = task.result as! String
          mainTask.setResult(matchedMovieName)
        }
        return nil
    }
    return mainTask.task
  }
  
  private class func uploadImageToImgur(imageToUpload: UIImage) -> BFTask {
    let task = BFTaskCompletionSource()
    let image = imageToUpload
    let imgData = UIImageJPEGRepresentation(image, 0.6)
    let data = imgData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    Alamofire.request(.POST, "https://api.imgur.com/3/image",
      parameters: ["image" : data!, "type" : "base64"],
      headers: [
        "Authorization" : "Client-ID cb03901569d8f77",
        "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:35.0) Gecko/20100101 Firefox/35.0",
        "Accept" : "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language" : "en-US,en;q=0.5",
        "Accept-Encoding" : "gzip, deflate"
      ]).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
      if let responseValue = response.result.value {
        let json = JSON(responseValue)
        let posterImageURL = json["data"]["link"].stringValue
          task.setResult(posterImageURL)
      }
    }
    return task.task
  }

  private class func userCountryCode() -> BFTask {
    let task = BFTaskCompletionSource()
    Alamofire.request(.GET, "http://ip-api.com/json").responseJSON { (response: Response<AnyObject, NSError>) -> Void in
      if let responseValue = response.result.value {
        let json = JSON(responseValue)
        let countryCode = json["countryCode"].stringValue
        task.setResult(countryCode)
      }
    }
    return task.task
  }
  
  private class func findMovieFor(posterImageURL: String, inRegionWithRegionCode: String) -> BFTask {
    let task = BFTaskCompletionSource()
    let regionCode = inRegionWithRegionCode
    Alamofire.request(
      .GET, "https://www.google.\(regionCode)/searchbyimage?site=search&sa=X&image_url=\(posterImageURL)",
      headers: ["User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:42.0) Gecko/20100101 Firefox/42.0"]
      ).responseString { (responseString: Response<String, NSError>) -> Void in
        if let html = responseString.result.value {
          let searchField = html.rangeOfString("\"sbiq\":")
          if let range = searchField {
            let tempString = html.substringWithRange(Range<String.Index>(start: range.endIndex.advancedBy(1), end: html.endIndex))
            let tempRange = tempString.rangeOfString("\"")
            if let tempRange = tempRange {
              let lengthToAdvance: Int = tempString.startIndex.distanceTo(tempRange.startIndex)
              let mathedMovieName = html.substringWithRange(Range<String.Index>(start: range.endIndex.advancedBy(1), end: range.endIndex.advancedBy(lengthToAdvance+1)))
              task.setResult(mathedMovieName)
          }
        }
      }
    }
    return task.task
  }
  
        
        
  
}


