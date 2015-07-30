//
//  Auth.swift
//  Reviews
//
//  Created by Admin on 17/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit
import OAuthSwift
import SwiftyJSON
import VK_ios_sdk
import InstagramKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import FastImageCache
import KeychainAccess



class Auth: UIViewController, VKSdkDelegate, GIDSignInUIDelegate {
    
    
    
    
    var textArray: NSMutableArray! = NSMutableArray()
    
    var vkontakteAcessToken: VKAccessToken? = nil
    var facebookAcessToken: String? = nil
    var googleAccessToken: String? = nil
    
    
    let instagramKeychain = Keychain(server: "https://api.instagram.com/oauth/authorize", protocolType: .HTTPS, authenticationType: .HTMLForm)
    let vkontakteKeychain = Keychain(server: "https://oauth.vk.com/authorize", protocolType: .HTTPS, authenticationType: .HTMLForm)

    
    
   
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
        
    }
   
    
    
    func googleAuth(){
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "1095542523991-7s9j46knl20bhge5ggv6ctbn0be6bf0f.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    func  twitterAuth(){
        Twitter.sharedInstance().logInWithCompletion {
            (session, error) -> Void in
            if (session != nil) {
                print("twitter: ok")
            } else {
                println("error: \(error.localizedDescription)");
            }
        }
    }
    
    
    
    
    func instagramAuth(){
        
        
        let instagramConsumerKey = "1c2e2066145342c3a841bdbdca8e53ae"
        let instagramConsumerSecret = "db9f79ad45b04fc09e8222645cb713b2"
        let instagramAuthorizeURL = "https://api.instagram.com/oauth/authorize"
        
        let auth = OAuth2Swift(
            consumerKey:    instagramConsumerKey,
            consumerSecret: instagramConsumerSecret,
            authorizeUrl:   instagramAuthorizeURL,
            responseType:   "token"
        )
        
        auth.authorize_url_handler = WebVC()
        self.view.opaque = false
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        if let at = self.instagramKeychain.get("access_token"){
            let url :String = "https://api.instagram.com/v1/users/self/?access_token=\(at)"
            let parameters :Dictionary = Dictionary<String, AnyObject>()
            auth.client.get(url, parameters: parameters,
                success: {
                    data, response in
                    let json = JSON(data: data)
             //       self.testLoginLabel.text = json["data"]["full_name"].string
                    // println(json)
                    
                    
                    
                    
                }, failure: {(error:NSError!) -> Void in
                    println(error)
            })
            
        }
        else {
            
            auth.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/instagram")!,
                scope: "likes+comments",
                state:"INSTAGRAM",
                success: {
                    credential, response, parameters in
                    
                    
                    self.instagramKeychain.set(credential.oauth_token, key: "access_token")
                    
                    
                    /*
                    [engine getMediaForUser:user.Id
                    count:15
                    maxId:self.currentPaginationInfo.nextMaxId
                    withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo)
                    {
                    if (paginationInfo) {
                    self.currentPaginationInfo = paginationInfo;
                    }
                    ...
                    }
                    failure:^(NSError *error)
                    {
                    ...
                    }];
                    */
                    
                    
                    let engine = InstagramEngine.sharedEngine()
                    /*
                    engine.getSelfUserDetailsWithSuccess({
                    success     in
                    }, failure: { (error:NSError!)   in
                    
                    })
                    */
                    
                    
                    /*
                    let url :String = "https://api.instagram.com/v1/users/self/?access_token=\(credential.oauth_token)"
                    let parameters :Dictionary = Dictionary<String, AnyObject>()
                    auth.client.get(url, parameters: parameters,
                    success: {
                    data, response in
                    let json = JSON(data: data)
                    self.testLoginLabel.text = json["data"]["full_name"].string
                    // println(json)
                    
                    
                    
                    
                    }, failure: {(error:NSError!) -> Void in
                    println(error)
                    })
                    
                    
                    */
                },
                
                failure: {(error:NSError!) -> Void in
                    println(error.localizedDescription)
            })
        }
    }
    
    
    
    
    
    func facebookAuth(){
        if ((FBSDKAccessToken.currentAccessToken()) != nil){
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.startWithCompletionHandler({
                (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                if(error != nil){
                    // process error
                }
                else{
                    let json = JSON(result)
            //        self.testLoginLabel.text = json["name"].string
                }
            })
        }
            
        else{
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.loginBehavior = FBSDKLoginBehavior.Web
            fbLoginManager.logInWithReadPermissions(["email"], handler: {
                (result: FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if ((error) != nil){
                    fbLoginManager.loginBehavior = FBSDKLoginBehavior.Web
                }
                else if (result.isCancelled){
                } else {
                    if(result.grantedPermissions.contains("email")){
                        print(result)
                    }
                }
            })
        }
    }
    
    
    func vkontakteAuth(){
        VKSdk.initializeWithDelegate(self, andAppId: "4991711")
        if (!VKSdk.isLoggedIn()) {
            //    let scope = NSMutableArray()
            //    scope.addObject("friends,profile info,offline,wall")
            //    VKSdk.authorize(scope as [AnyObject])
            VKSdk.authorize(["friends,profile info,offline,wall"])
        }
        else {
            let audioReq: VKRequest = VKApi.users().get()
            audioReq.executeWithResultBlock({
                response in
                let json = JSON(response.json)
           //     self.testLoginLabel.text = json[0]["first_name"].string! + " " + json[0]["last_name"].string!
                for (key, subJson) in json[0] {
                    if let title = subJson[key].string {
                        println(title)
                    }
                }
                println("//////////////////")
                if let title = json[0]["first_name"].string {
                    println(title)
                }
                if let title = json[0]["last_name"].string {
                    println(title)
                }
                if let title = json[0][1].string {
                    println(title)
                }
                else{
                    println("ID - FAIL!")
                }
                println(response.json)
                },
                errorBlock: {(error:NSError!) -> Void in
                    println(error.localizedDescription)
            })
        }

        
    }
    
    
    
    func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
        self.vkontakteAcessToken = newToken
    }
    
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        VKSdk.getAccessToken()
    }
    
    func vkSdkUserDeniedAccess(authorizationError: VKError!) {
        
    }
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        let vc = controller
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        let vc = VKCaptchaViewController.captchaControllerWithError(captchaError)
        vc.presentIn(self)
    }
    
}







