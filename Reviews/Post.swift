//
//  Post.swift
//  Reviews
//
//  Created by Admin on 02/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit

class Post{
    var userName = "userName"
    var timeSincePosted = "three hours ago"
    var profileImage:UIImage? = UIImage()
    var posterImage:UIImage? = UIImage()
    // var topCell:CustomCell? = CustomCell()
    //  var contentCell:CustomCell? = CustomCell()
   
    
    init (userName: String, timeSincePosted: String, profileImage: UIImage?, posterImage: UIImage?){
        self.userName = userName
        self.timeSincePosted = timeSincePosted
        self.profileImage = profileImage
        self.posterImage = posterImage
    }
    
}