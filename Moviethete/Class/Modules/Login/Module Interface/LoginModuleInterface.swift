//
//  LoginModuleInterface.swift
//  Moviethete
//
//  Created by Alexander Abdulov on 8/9/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

protocol LoginModuleInterface {
	func login(email: String, password: String)
	func loginWithSocialNetwork(socialNetwork: SocialNetwork)
	func signUp(email: String, password: String, username: String?)
	func showLoginError(error: LoginError)
	func showSignUpError(error: SignUpError)
	func showLoginInputError(error: LoginInputError)
	func showSignUpInputError(error: SignUpInputError)
	func proceedToMainScreen()
	func cancelLogin()
}