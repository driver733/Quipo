//
//  Extentions.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 12/8/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import Foundation
import VK_ios_sdk
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Bolts
import SwiftyJSON
import Parse
import ObjectiveC

// Localization for IB support
//#define MLLocalizedString(key, comment)
//[[NSBundle bundleForClass:[AppDelegate class]] localizedStringForKey:(key) value:@"" table:nil]
//#define MLLocalizedStringFromTable(key, tbl, comment)
//[[NSBundle bundleForClass:[AppDelegate class]] localizedStringForKey:(key) value:@"" table:(tbl)]



private var xoAssociationKey: UInt8 = 0

extension LoadingStateDelegate {
  
  func didStartNetworingActivity() {
    let loadingStateView = LoadingIndicatorView()
    UIViewController.currentViewController().view.addSubview(loadingStateView)
  }
  
  func didEndNetworingActivity() {
    if let loadingView = UIViewController.currentViewController().view.viewWithTag(LoadingIndicatorViewTag) as? LoadingIndicatorView {
      loadingView.toggleTickWithTimeIntervalExpirationBlock({ () -> Void in
      })
    }
  }
  
}

extension String {
  func sizeForWidth(width: CGFloat, font: UIFont) -> CGSize {
    let attr = [NSFontAttributeName: font]
    let height = NSString(string: self).boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options:.UsesLineFragmentOrigin, attributes: attr, context: nil).height
	
    return CGSize(width: width, height: ceil(height))
  }
}


@IBDesignable class BorderedButton : UIButton {}

extension UIView {

	@IBInspectable var locKey: String {
		get {
			return objc_getAssociatedObject(self, &xoAssociationKey) as! String
		}
		set(newValue) {
//			objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
			didSetLocKey(newValue)
		}
	}

	func localizedString(locKey: String, comment: String) -> String {
		return NSBundle(forClass: self.dynamicType).localizedStringForKey(locKey, value: "", table: nil)
	}
	
	func localizedStringFromTable(locKey: String, tableName: String, comment: String) -> String {
		return NSBundle(forClass: self.dynamicType).localizedStringForKey(locKey, value: "", table: tableName)
	}
	
	
	private func didSetLocKey(lokKey: String) {
		if lokKey.characters.count > 0 {
			let locString = localizedStringFromTable(lokKey, tableName: "LogIn", comment: "")
			if self.isKindOfClass(UIButton) {
				(self as! UIButton).setTitle(locString, forState: .Normal)
			} else if self.isKindOfClass(UILabel) {
				(self as! UILabel).text = locString
			} else if self.isKindOfClass(UITextView) {
				(self as! UITextView).text = locString
			} else if self.isKindOfClass(UITextField) {
				(self as! UITextField).text = locString
			} else if self.isKindOfClass(UITextField) {
				(self as! UITextField).text = locString
			} else if self.isKindOfClass(UIImageView) {
				(self as! UIImageView).image = UIImage(named: locString, inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
			}
		}
	}
	
	
  class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
    return UINib(
		nibName: nibNamed,
		bundle: bundle
      ).instantiateWithOwner(nil, options: nil)[0] as? UIView
  }
	
	
	
}

extension UITableViewCell {
  
  class func loadingIndicatorCell(superview: UIView) -> UITableViewCell {
    let cell = UITableViewCell(frame: CGRectMake(0, 0, superview.frame.width, 10))
    let loadingIndicator = UIActivityIndicatorView(frame: CGRectMake(cell.center.x, cell.center.y, 10, 10)) as UIActivityIndicatorView
    loadingIndicator.center.x = superview.center.x
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    cell.addSubview(loadingIndicator)
    loadingIndicator.startAnimating()
    return cell
  }
  
  class func noSearchResultsCell(superview: UIView) -> UITableViewCell {
    let cell = UITableViewCell(frame: CGRectMake(0, 0, superview.frame.width, 20))
    let label = UILabel(frame: CGRectMake(0, 10, 120, 20))
    label.center.x = superview.center.x
    label.text = "No Results"
    label.textColor = UIColor.grayColor()
    label.font = UIFont.boldSystemFontOfSize(20)
    cell.addSubview(label)
    return cell
  }
  
}

extension UIViewController {
  
  class func screenshot() -> UIImage {
    let layer = UIApplication.sharedApplication().keyWindow!.layer
    let scale = UIScreen.mainScreen().scale
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
    layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let screenshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return screenshot
  }
  
  func subViewWithRestorationID(restorationID: String) -> UIView? {
    for view in self.view.subviews {
      if view.restorationIdentifier == restorationID {
        return view
      }
    }
    return nil
  }
  
  func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
  func primaryPosterImageColorAndtextColor(posterImage: UIImage) -> (primaryColor: UIColor, inferredTextColor: UIColor) {
    var colors: (primaryColor: UIColor, inferredTextColor: UIColor)
    let uiColor = posterImage.getColors(CGSizeMake(50, 50)).primaryColor
    let newColor = primaryColorComponent(uiColor)
    if newColor != "normal" {
      let backgroundUiColor = posterImage.getColors(CGSizeMake(50, 50)).backgroundColor
      let testBackroundColor = primaryColorComponent(backgroundUiColor)
      if testBackroundColor != "normal" {
        if testBackroundColor == "black" {
          colors.inferredTextColor = UIColor.whiteColor()
          colors.primaryColor = backgroundUiColor
          return colors
        } else {
          colors.inferredTextColor = UIColor.blackColor()
          colors.primaryColor = backgroundUiColor
          return colors
        }
      } else {
        colors.inferredTextColor = UIColor.whiteColor()
        colors.primaryColor = backgroundUiColor
        return colors
      }
    } else {
      colors.inferredTextColor = UIColor.whiteColor()
      colors.primaryColor = uiColor
      return colors
    }
  }
  
  /// Determines whether the color is, for the most part, white, black, or neither.
  func primaryColorComponent(theColor: UIColor) -> String {
    let color = theColor.CGColor
    let numComponents = CGColorGetNumberOfComponents(color)
    if numComponents == 4 {
      let components = CGColorGetComponents(color)
      let red = components[0]
      let green = components[1]
      let blue = components[2]
      if red < 0.3 && green < 0.3 && blue < 0.3 {
        return "black"
      } else if red > 0.7 && green > 0.7 && blue > 0.7 {
        return "white"
      } else {
        return "normal"
      }
    }
    return ""
  }
}

extension UIColor {
  convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
  }
  class func pencilColor() -> UIColor {
    return UIColor(r: 230, g: 230, b: 230)
  }
  class func searchBarSuperviewBackgroundColor() -> UIColor {
    return UIColor(r: 250, g: 250, b: 250)
  }
  class func placeholderColor() -> UIColor {
    return UIColor(r: 240, g: 240, b: 240)
  }
  class func quipoColor() -> UIColor {
    return UIColor(r: 103, g: 80, b: 182)
  }
}



extension UIViewController {
  class func currentViewController() -> UIViewController {
    var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
    while ((topController?.presentedViewController) != nil) {
      topController = topController?.presentedViewController
    }
    return topController!
  }
}






extension FBSDKAccessToken {
  
  /**
   Refreshes Facebook access token and then reloads FBSDKProfile.currentProfile() if nessessary.
   */
  class func refreshCurrentAccessToken() -> BFTask {
    let task = BFTaskCompletionSource()
    FBSDKAccessToken.refreshCurrentAccessToken { (_, _, error: NSError!) -> Void in
      if error == nil {
        task.setResult(nil)
      } else {
        return task.setResult(error)
      }
    }
    return task.task
  }
  
}


extension PFQuery {
  
  class func usernameIfRegistered(authID: String) -> BFTask {
    let task = BFTaskCompletionSource()
    let query = PFUser.query()
    query?.whereKey("authID", equalTo: authID)
    query?.getFirstObjectInBackgroundWithBlock({
      (foundUser: PFObject?, error: NSError?) -> Void in
      if error == nil, let user = foundUser as? PFUser {
        task.setResult(user.username!)
      }
      else {
        task.setResult(nil)
      }
    })
    return task.task
  }
  
}









