//
//  LoginWireframe.swift
//  Moviethete
//
//  Created by Alexander Abdulov on 8/9/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

// let ListViewControllerIdentifier = "ListViewController"

class LoginWireframe : NSObject {
	
	var loginPresenter : LoginPresenter?
	var rootWireframe : RootWireframe?
	var mainWireframe : MainWireframe?
	var presentedViewController : LogInVC?
	
	func presentLoginInterfaceFromWindow(window: UIWindow) {
		let viewController = loginVCFromNIB()
		viewController.eventHandler = loginPresenter
		presentedViewController = viewController
		loginPresenter!.userInterface = viewController
		rootWireframe?.showRootViewController(viewController, inWindow: window)
	}
	
	func showAlert(withTitle: String, andMessage: String) {
		let alert = UIAlertController(title: withTitle, message: andMessage, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))

	}
	
	
	
	func proceedToMainScreen() {
		mainWireframe?.presentMainInterfaceFromViewControler(presentedViewController!)
	}
	
	
	
	func loginVCFromNIB() -> LogInVC {
		let viewController = UIViewController.init(nibName: "LogIn", bundle: NSBundle.mainBundle()) as! LogInVC
		return viewController
	}
	
	
}