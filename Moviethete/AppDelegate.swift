//
//  AppDelegate.swift
//  Reviews
//
//  Created by Admin on 17/06/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import OAuthSwift
import FBSDKCoreKit
import VK_ios_sdk
import Bolts
import SDWebImage
import Parse
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate
{

    var window: UIWindow?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("FHtrAm8LOVA1UWPNicmSXd4xn8Zpq7NM1fkLtb11",
            clientKey: "Ul05iFZTBIIKGEfwUnagU7nUTTcs1Cm8sH1VXNbg")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        
        Fabric.with([Twitter()])
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Initialize sign-in
        var configureError: NSError?
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().delegate = self
        
        PFTwitterUtils.initializeWithConsumerKey("IeJhyNYLW5bgaZtrQTJ9Rq7Vb",  consumerSecret:"Ze2eFiBSVHA1dIOM8bu2gsK2cBO9Maw4nmqVzbJUv9B82G9vaw")
        
        if (PFUser.currentUser() != nil) {
          self.window?.rootViewController? = (self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("main"))!
        }
      
      
   //   self.window?.rootViewController?.tabBarController!.delegate = self
    //  ((self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("main"))! as! UITabBarController).delegate = self
      
      
      
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
  //      GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
        FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        VKSdk.processOpenURL(url, fromApplication: sourceApplication)
        if (url.host == "oauth-callback") {
                if (url.path!.hasPrefix("/instagram")){
                OAuth2Swift.handleOpenURL(url)
            }
        }
        return true
    }
    
 
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error != nil){
        }
        else{
            

        }
    }
    
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
    
    

    


}











