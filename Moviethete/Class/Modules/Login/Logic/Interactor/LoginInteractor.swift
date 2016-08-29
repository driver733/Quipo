//
//  LoginInteractor.swift
//  Moviethete
//
//  Created by Alexander Abdulov on 8/9/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation
import ReactiveCocoa

class LoginInteractor : LoginInteractorInputDelegate {
	var output : LoginInteractorOutputDelegate?
	
	let dataManager : LoginDataManager
	
	init(dataManager: LoginDataManager) {
		self.dataManager = dataManager
	}
	
	func login(email: String, password: String) {
		
		dataManager.loginWithParse(email, password: password).signal.observe(Signal.Observer { event in
			switch event {
			case let .Failed(error):
				self.output?.loggedIn(false)
				print("Failed: \(error)")
			case .Completed:
				self.output?.loggedIn(true)
				print("Completed")
			default:
				self.output?.loggedIn(false)
			}
			})
	
	}
	
	func signUp(email: String, password: String, username: String?) {
		dataManager.signUpWithParse(email, password: password, username: username).signal.observe(Signal.Observer { event in
			switch event {
			case let .Failed(error):
				self.output?.signedUp(false)
				print("Failed: \(error)")
			case .Completed:
				self.output?.signedUp(true)
				print("Completed")
			default:
				self.output?.signedUp(false)
			}
			})
	}
	
	
	
	
}