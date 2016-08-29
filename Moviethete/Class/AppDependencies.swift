//
//  AppDependencies.swift
//  Moviethete
//
//  Created by Alexander Abdulov on 8/10/16.
//  Copyright © 2016 BIBORAM. All rights reserved.
//

import Foundation
import UIKit


class AppDependencies {
	var loginWireframe = LoginWireframe()
	var mainWireframe = MainWireframe()
	
	init() {
		configureDependencies()
	}
	
	
	
	func installRootViewControllerIntoWindow(window: UIWindow) {
		loginWireframe.presentLoginInterfaceFromWindow(window)
	}
	
	func configureDependencies() {
		
	}

}