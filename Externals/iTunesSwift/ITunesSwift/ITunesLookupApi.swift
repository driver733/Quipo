//
//  ITunesLookupApi.swift
//  ITunesSwift
//
//  Created by Kazuyoshi Tsuchiya on 2014/09/21.
//  Copyright (c) 2014 tsuchikazu. All rights reserved.
//

import Foundation
import Alamofire

public class ITunesLookupApi {
    let url = "https://itunes.apple.com/lookup"
    
    var idName: String
    var id: Int
    
    public init(idName: String, id: Int) {
        self.idName = idName
        self.id = id
    }
    
    public func request(completionHandler: (String?, NSError?) -> Void) -> Void {
      
      Alamofire.request(.GET, self.buildUrl()).responseString { (response: Response<String, NSError>) -> Void in
        completionHandler(response.result.value, response.result.error)
      }
      
//      Alamofire.request(.GET, self.buildUrl())
//            .responseString { (request: NSURLRequest?, response: NSHTTPURLResponse?, result: Result<String>) -> Void in
//              let err = NSError(domain: "", code: 0, userInfo: ["":""])
//                completionHandler(result.value, err)
//        }
    }
    
    internal func buildUrl() -> String {
        let queryString: String = "?" + idName + "=" + String(id)
        
        return self.url + queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
}
