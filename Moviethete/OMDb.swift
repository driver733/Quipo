//
//  OMDb.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 12/6/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import Foundation
import Bolts



class OMDb {
  
}



extension OMDBAPI {
  
  func advancedSearchByTitle(post: Post, title:String, type:OMDBAPITypes? = nil,year:Int? = nil, fullPlot:Bool? = false, tomatoes:Bool? = false) -> BFTask {
    var searchQuery="?t=\(title)"
    
    if let type = type {
      switch(type) {
      case .Movie:
        searchQuery += "&type=movie"
      case .Series:
        searchQuery += "&type=series"
      case .Episode:
        searchQuery += "&type=episode"
      }
    }
    if let year = year {
      searchQuery += "&y=\(year)"
    }
    
    if let fullPlot = fullPlot {
      if fullPlot {
        searchQuery += "&plot=full"
      }
      else {
        searchQuery += "&plot=short"
      }
    }
    
    if let tomatoes = tomatoes {
      if tomatoes {
        searchQuery += "&tomatoes=true"
      }
      else {
        searchQuery += "&tomatoes=false"
      }
    }
    
    searchQuery += "&r=json"
    
    let encodedSearchQuery = searchQuery.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    
    return advancedSearchByQuery(post, query: encodedSearchQuery!)
  }
  
  private func advancedSearchByQuery(post: Post, query:String) -> BFTask {
    let bftask = BFTaskCompletionSource()
    let baseUrl = NSURL(string: kBaseURL)!
    let url = NSURL(string: query, relativeToURL:baseUrl)!
    let request = NSMutableURLRequest(URL: url)
    let urlSession = NSURLSession.sharedSession()
    let task = urlSession.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
      if error != nil {
        print(error!.localizedDescription)
      }
      do {
        let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
        let movie = Movie(jsonDict: jsonResult!)
        post.OMDB = movie
        bftask.setResult(post)
      }
      catch {
        print("Could not convert result to json dictionary")
      }
    })
    task.resume()
    return bftask.task
  }
  
  
  private func processPost() {
    
  }
  
}






