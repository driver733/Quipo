//
//  LoginInteractorIO.swift
//  Moviethete
//
//  Created by Alexander Abdulov on 8/9/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation
import ReactiveCocoa

enum SocialNetwork {
	case FACEBOOK
	case INSTAGRAM
	case VKONTAKTE
	case TWITTER
	case GOOGLE
	case PARSE
}


protocol LoginInteractorInputDelegate {
	func login(email: String, password: String)
	func signUp(email: String, password: String, username: String?)
	//func loginWithSocialNetwork(socialNetwork: SocialNetwork) -> Signal<Void, LoginError>
}

protocol LoginInteractorOutputDelegate {
	func loggedIn(successfully: Bool)
	func signedUp(successfully: Bool)
}