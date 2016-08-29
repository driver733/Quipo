//
//  FeedWireframe.swift
//  Moviethete
//
//  Created by Alexander Abdulov on 8/10/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class MainWireframe : NSObject {
	

	var rootWireframe : RootWireframe?
	var mainVC : UITabBarController?
	
	func presentMainInterfaceFromWindow(window: UIWindow) {
		let viewController = mainTabBarVCFromStoryBoard()
		mainVC = viewController
		rootWireframe?.showRootViewController(viewController, inWindow: window)
	}
	
	func presentMainInterfaceFromViewControler(viewController: UIViewController) {
		let newMainViewController = mainTabBarVCFromStoryBoard()
		mainVC = newMainViewController
		viewController.presentViewController(newMainViewController, animated: true, completion: nil)
	}
	
	func mainTabBarVCFromStoryBoard() -> UITabBarController {
		let viewController = mainStoryboard().instantiateViewControllerWithIdentifier("main") as! UITabBarController
		return viewController
	}
	
	func mainStoryboard() -> UIStoryboard {
		let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		return storyboard
	}

}

