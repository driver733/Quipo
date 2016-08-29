//
//  LoginErrors.swift
//  Moviethete
//
//  Created by Alexander Abdulov on 8/11/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

enum LoginInputError : ErrorType {
	case IncorrectEmail
	case IncorrectPassword
}

enum SignUpInputError : ErrorType {
	case InvalidEmail
	case InvalidPassword
	case InvalidUsername
}