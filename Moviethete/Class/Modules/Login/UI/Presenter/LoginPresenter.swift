//
//  LoginPresenter.swift
//  Moviethete
//
//  Created by Alexander Abdulov on 8/9/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class LoginPresenter: LoginModuleInterface {
	
	var loginInteractor : LoginInteractorInputDelegate?
	var loginWireframe : LoginWireframe?
	var userInterface : LoginViewInterface?
	
	func login(email: String, password: String) {
		loginInteractor?.login(email, password: password)
	}
	
	func signUp(email: String, password: String, username: String?) {
		loginInteractor?.signUp(email, password: password, username: username)
	}
	
	
	func showLoginError(error: LoginError) {
	loginWireframe?.showAlert("", andMessage: "")
	}
	
	func showSignUpError(error: SignUpError) {
		loginWireframe?.showAlert("", andMessage: "")
	}
	
	func showLoginInputError(error: LoginInputError) {
		loginWireframe?.showAlert("", andMessage: "")
	}
	
	func showSignUpInputError(error: SignUpInputError) {
		loginWireframe?.showAlert("", andMessage: "")
	}
	
	func loginWithSocialNetwork(socialNetwork: SocialNetwork) {
		//	loginInteractor?.loginWithSocialNetwork(socialNetwork)
	}
	
	func proceedToMainScreen() {
		loginWireframe?.proceedToMainScreen()
	}
	

	func cancelLogin() {
		
	}
	
}

extension LoginPresenter : LoginInteractorOutputDelegate {
	
	func loggedIn(successfully: Bool) {
		proceedToMainScreen()
	}
	
	func signedUp(successfully: Bool) {
		proceedToMainScreen()
	}
	
}



