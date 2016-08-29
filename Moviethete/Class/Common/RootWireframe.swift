//
//  RootWireframe.swift
//  Moviethete
//
//  Created by Alexander Abdulov on 8/9/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation

class RootWireframe {
	func showRootViewController(viewController: UIViewController, inWindow: UIWindow) {
		let navigationController = navigationControllerFromWindow(inWindow)
		navigationController.viewControllers = [viewController]
	}
	
	func navigationControllerFromWindow(window: UIWindow) -> UINavigationController {
		let navigationController = window.rootViewController as! UINavigationController
		return navigationController
	}
}