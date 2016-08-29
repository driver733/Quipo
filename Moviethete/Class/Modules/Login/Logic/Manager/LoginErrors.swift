//
//  LoginErrors.swift
//  Moviethete
//
//  Created by Alexander Abdulov on 8/10/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation


enum LoginError : Int, ErrorType {
	case UNKNOWN = 0
	case CREDENTIALS = 1
}

enum SignUpError : Int, ErrorType {
	case UNKNOWN = 0
	case USERNAME_TAKEN = 1
}