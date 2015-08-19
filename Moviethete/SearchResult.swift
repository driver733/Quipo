//
//  SearchResult.swift
//  Moviethete
//
//  Created by Mike on 8/16/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import Foundation
import UIKit

struct searchResult {
    
  var movieTitle: String?
  var smallPosterImageURL: String?
  var bigPosterImageURL: String?
  var movieGenre: String?
  var releaseDate: String
  var friendsRating: String?
  var rottenTomatoesRating: String?
    
  init (theMovieTitle: String, theMovieGenre: String, theMovieReleaseDate: String, theSmallPosterImageURL: String, theBigPosterImageURL: String){
        movieTitle = theMovieTitle
        movieGenre = theMovieGenre
        releaseDate = theMovieReleaseDate
        smallPosterImageURL = theSmallPosterImageURL
        bigPosterImageURL = theBigPosterImageURL
    }
    
}
