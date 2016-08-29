//
// Created by Alexander Abdulov on 8/8/16.
// Copyright (c) 2016 BIBORAM. All rights reserved.
//

import Foundation
import Parse
import ReactiveCocoa
import FBSDKLoginKit


 class LoginDataManager {

    func loginWithParse(email: String, password: String) -> Signal<Void, LoginError> {
		
		return Signal { (subscriber: Observer<Void, LoginError>) -> Disposable? in
		
			var username = ""
			
			let query = PFUser.query()
			query?.whereKey("email", equalTo: email)
			query?.findObjectsInBackground().continueWithSuccessBlock({
				(task: BFTask!) -> AnyObject! in
				if task.error == nil, let foundUsers = task.result as? [PFObject] where foundUsers.count == 1 {
					for user in foundUsers {
						username = (user as! PFUser).username!
					}
				}
					  return PFUser.logInWithUsernameInBackground(username, password: password)
			})
			.continueWithBlock({ (task: BFTask!) -> AnyObject! in
				if task.error == nil {
					
					  subscriber.sendCompleted()
				  //
				  //	Move to checkUserLinkedAccounts and make it return BFTask
				  //					  
					
				  //CurrentUser.sharedCurrentUser().checkUserLinkedAccounts()
		//
	//			  // Move to checkUserLinkedAccounts and make it return BFTask
	//			  if FBSDKAccessToken.currentAccessToken() != nil && FBSDKProfile.currentProfile() == nil {
	//				  NSNotificationCenter.defaultCenter().addObserver(self, name: FBSDKProfileDidChangeNotification, object: nil, handler: { (observer, notification) -> Void in
	//					  BFTask(forCompletionOfAllTasks: [LinkedAccount.updateAll(), CurrentUser.sharedCurrentUser().loadLinkedAccountsFriends()])
	//					  .continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
	//																  
	//																  
	//                     self.pushMainVC()
	//																  
	//						  return nil
	//					  })
	//				  })
	//
	//			  } else {
	//				  // Move to checkUserLinkedAccounts and make it return BFTask
	//				  BFTask(forCompletionOfAllTasks: [LinkedAccount.updateAll(), CurrentUser.sharedCurrentUser().loadLinkedAccountsFriends()])
	//				  .continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
	//					  self.pushMainVC()
	//					  return nil
	//				  })
	//			  }
					

				} else if let errorCode = task.error?.code {
					
					switch errorCode {
					case 101:
						subscriber.sendFailed(LoginError.CREDENTIALS)
					default:
						subscriber.sendFailed(LoginError.UNKNOWN)
					}
					
					
				}
				return nil
			})
			
		return nil
			
		}
		
	}
	
	

	func signUpWithParse(email: String, password: String, username: String?) -> Signal<Void, SignUpError> {
		
		return Signal ({ (subscriber: Observer<Void, SignUpError>) -> Disposable? in
			
			let user = PFUser()
			if let username = username {
				user.username = username
			}
			else {
				let arr: Array = email.componentsSeparatedByString("@")
				user.username = arr[0]
			}
			user.password = password
			user.email = email
			user["smallProfileImage"] = "https://graph.facebook.com/133559250332613/picture?type=normal&width=100&height=100"
			user["bigProfileImage"] = "https://graph.facebook.com/133559250332613/picture?type=normal&width=600&height=600"
			user.signUpInBackground().continueWithBlock {
				(task: BFTask!) -> AnyObject! in
				if task.error == nil {
					subscriber.sendCompleted()
				} else if let errorCode = task.error?.code {
					
					switch errorCode {
						case 202:
							subscriber.sendFailed(SignUpError.USERNAME_TAKEN)
//							alert.title = "Username already taken"   // "Or email is already taken. Have trouble logging in? " -> Needs to take into account email too.
//							alert.message = "This username is already taken. Please use a different one."
//							Async.main {
//								self.presentViewController(alert, animated: true, completion: nil)
//							}
						default:
							subscriber.sendFailed(SignUpError.UNKNOWN)
						}
					
				}
				return nil
			}
			return nil
		})
	}
	
	
//	func loginWithSociaNetwork(socialNetwork: SocialNetwork) -> Signal<Void, LoginError> {
//
//		return Signal({ (observer: Observer<Void, LoginError>) -> Disposable? in
//			
//			return nil
//		})
	
		
		
		
	}






	





















