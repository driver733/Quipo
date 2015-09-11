//
//  Login.swift
//  Reviews
//
//  Created by Admin on 17/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import TwitterKit
import OAuthSwift
import SwiftyJSON
import VK_ios_sdk
import InstagramKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import KeychainAccess
import SwiftValidator
import FontBlaster
import Parse
import ParseFacebookUtilsV4



let DID_LOG_IN_SEGUE_IDENTIFIER = "didLogIn"



class LogInVC: UIViewController {
   
    @IBOutlet weak var signInTableView: UITableView!
    @IBOutlet weak var signUpTableView: UITableView!
    @IBOutlet weak var signInOrUp: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var shareThoughtsLabel: UILabel!
    @IBOutlet weak var signUpTriangle: UIView!
    @IBOutlet weak var signInTriangle: UIView!
    
  
    
    @IBAction func loginWithGoogle(sender: AnyObject) {
    GIDSignIn.sharedInstance().allowsSignInWithBrowser = false
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().clientID = "1095542523991-7s9j46knl20bhge5ggv6ctbn0be6bf0f.apps.googleusercontent.com"
    GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
    GIDSignIn.sharedInstance().signIn()
    
  }

    @IBAction func didLogOut(segue: UIStoryboardSegue) {
    }
    
    @IBAction func signUpButton(sender: AnyObject) {
      signInTableView.hidden = true
      signUpTableView.hidden = false
      signUpTableViewUserInteraction(true)
      signInTableViewUserInteraction(false)
      signUpTriangle.hidden = false
      signInTriangle.hidden = true
      orLabel.text = "or Sign Up with:"
      shareThoughtsLabel.text = "Sign Up \n and start sharing your thoughts"
      
    }
    @IBAction func signInButton(sender: AnyObject) {
      signUpTableView.hidden = true
      signInTableView.hidden = false
      signUpTableViewUserInteraction(false)
      signInTableViewUserInteraction(true)
      signUpTriangle.hidden = true
      signInTriangle.hidden = false
      orLabel.text = "or Sign In with:"
      shareThoughtsLabel.text = "Sign In \n and start sharing your thoughts"
    
    }
    
    @IBAction func startLogin(sender: AnyObject) {
        validator.validate(self)
    }
    
    
    let validator = Validator()
    var tempArr: [Int] = [Int]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var textArray: NSMutableArray! = NSMutableArray()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        FontBlaster.blast()
        NSBundle.mainBundle().loadNibNamed("LogIn", owner: self, options: nil)
        self.navigationController?.navigationBarHidden = true
        self.hidesBottomBarWhenPushed = true
        
        signInTableView.registerNib(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "Cell")
        signInTableView.delegate = self
        signInTableView.dataSource = self
        signInTableView.rowHeight = UITableViewAutomaticDimension;
        signInTableView.estimatedRowHeight = 44.0;
        
        signUpTableView.registerNib(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "Cell")
        signUpTableView.delegate = self
        signUpTableView.dataSource = self
        signUpTableView.rowHeight = UITableViewAutomaticDimension;
        signUpTableView.estimatedRowHeight = 44.0;
        signUpTableView.hidden = true
    
        orLabel.font = UIFont(name: "Nanum Pen", size: orLabel.font.pointSize)
        signInButton.titleLabel?.font = UIFont(name: "Nanum Pen", size: signInButton.titleLabel!.font.pointSize)
        signUpButton.titleLabel?.font = UIFont(name: "Nanum Pen", size: signUpButton.titleLabel!.font.pointSize)
  
        signInOrUp.titleLabel?.font = UIFont(name: "Nanum Pen", size: signUpButton.titleLabel!.font.pointSize)
        
        shareThoughtsLabel.text = "Sign In \n  and start sharing your thoughts"
        shareThoughtsLabel.font = UIFont(name: "Nanum Pen", size: shareThoughtsLabel.font.pointSize)
        shareThoughtsLabel.numberOfLines = 0
      
        signInTriangle.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        signUpTriangle.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        signUpTriangle.hidden = true
      
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFacebookProfile:", name: FBSDKProfileDidChangeNotification, object: nil)
      
      
      
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    UserSingelton.sharedInstance.followFriendsData.removeAll(keepCapacity: false)
//    UserSingelton.sharedInstance.allFriends.removeAll(keepCapacity: false)
//    
//    UserSingelton.sharedInstance.vkontakteFriends.removeAll(keepCapacity: false)
//    UserSingelton.sharedInstance.facebookFriends.removeAll(keepCapacity: false)
//    
//    
//    
//    UserSingelton.sharedInstance.loadFollowFriendsData()
  }
  
  func signUpTableViewUserInteraction(condition: Bool){
    for var section = 0; section < signUpTableView.numberOfSections; ++section {
      for var row = 0; row < signUpTableView.numberOfRowsInSection(section); ++row {
        let cellPath = NSIndexPath(forRow: row, inSection: section)
        let signUpCell: Cell = signUpTableView.cellForRowAtIndexPath(cellPath) as! Cell
        signUpCell.textfield.userInteractionEnabled = condition
      }
    }
  }
  
  
  
  func signInTableViewUserInteraction(condition: Bool) {
    for var section = 0; section < signInTableView.numberOfSections; ++section {
      for var row = 0; row < signInTableView.numberOfRowsInSection(section); ++row {
        let cellPath = NSIndexPath(forRow: row, inSection: section)
        let signInCell: Cell = signInTableView.cellForRowAtIndexPath(cellPath) as! Cell
        signInCell.textfield.userInteractionEnabled = condition
      }
    }
  }
  
  
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
  
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
  
    func signIn(){
      
        let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        var username = ""
        let email = (signInTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! Cell).textfield.text
        let password = (signInTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! Cell).textfield.text!
        let query = PFUser.query()
        query?.whereKey("email", equalTo: email!)
        query?.findObjectsInBackground().continueWithSuccessBlock({
          (task: BFTask!) -> AnyObject! in
        if task.error == nil, let foundUsers = task.result as? [PFObject] where foundUsers.count == 1 {
          for user in foundUsers {
            username = (user as! PFUser).username!
          }
        }
        return task
        }).continueWithBlock({ (task: BFTask!) -> AnyObject! in
          if task.error == nil {
            
            PFUser.logInWithUsernameInBackground(
              username,
              password: password,
              block: {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                  self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
                } else {
                  switch error!.code {
                  case 101:
                    alert.title = "Incorrect Email or Password"
                    alert.message = "Please check your Email and Password!"
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                  default: break
                  }
                }
                
            })

          }
          
        return nil
          
        })
      
      
      
          
    }
    
    
    func SignUp(){
      
      
        let user = PFUser()
        let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        if !(signUpTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! Cell).textfield.text!.isEmpty {
            user.username = (signUpTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! Cell).textfield.text
        }
        else {
            let arr: Array = ((signUpTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! Cell).textfield.text?.componentsSeparatedByString("@"))!
         user.username = arr[0]
        }

        
        user.password = (signUpTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! Cell).textfield.text
        user.email = (signUpTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! Cell).textfield.text
        
        // other fields can be set just like with PFObject
      
      user.signUpInBackground().continueWithBlock {
        (task: BFTask!) -> AnyObject! in
        if task.error == nil {
          self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
        } else {
          switch task.error.code {
          case 202:
            alert.title = "Username already taken"   // "Or email is already taken. Have trouble logging in? " -> Needs to take into account email too.
            alert.message = "This username is already taken. Please use a different one."
            self.presentViewController(alert, animated: true, completion: nil)
          default: break
          }

        }
        return nil
      }
      
      
      
      
    }
  
  
  
  

    
  
    @IBAction func buttonTwitterLogin(sender: AnyObject) {
      
        Twitter.sharedInstance().logInWithCompletion { session, error in
            if (session != nil) {
                self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
            } else {
            
            }
        }

    }
    
    
    @IBAction func loginWithInstagram(sender: AnyObject) {
        
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
        
            auth.authorizeWithCallbackURL(
                NSURL(string: "oauth-swift://oauth-callback/instagram")!,
                scope: "likes+comments",
                state:"INSTAGRAM",
                success: {
                  credential, response, parameters in
                    
                    let engine = InstagramEngine.sharedEngine()
                    engine.accessToken = credential.oauth_token
                    UserSingelton.sharedInstance.instagramKeychain["instagram"] = credential.oauth_token
                    
                    engine.getSelfUserDetailsWithSuccess({
                      (user: InstagramUser!) -> Void in
                        let userName =   user.username
                        let userID =     user.Id
                        let smallPhoto = user.profilePictureURL
                        let bigPhoto =   user.profilePictureURL
                      
                      self.getUsernameifRegistered("INSTM\(userID)").continueWithBlock({
                        (task: BFTask!) -> AnyObject! in
                        if task.error == nil, let username = task.result as? String {
                          
                          PFUser.logInWithUsernameInBackground(username, password: "").continueWithBlock({
                            (task: BFTask!) -> AnyObject! in
                            if task.error == nil {
                              self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
                            } else {
                              // process error
                            }
                            return nil
                          })
                          
                        } else {
                          let user = PFUser()
                          user.username = userName
                          user.password = ""
                          user["authID"] = "INSTM\(userID)"
                          user["INSTMID"] = userID
                          user["smallProfileImage"] = "\(smallPhoto)"
                          user["bigProfileImage"] = "\(bigPhoto)"
                          
                          user.signUpInBackground().continueWithBlock({
                            (task: BFTask!) -> AnyObject! in
                            if task.error == nil {
                              self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
                            } else {
                              switch task.error.code {
                              case 202:   // parse: "username already taken"
                                self.extendUsernameWithUserIDAndRegister("\(userID)", user: user)
                              default: break
                              }
                            }
                            return nil
                          })
                          
                        }
                        return nil
                      })
                     
                                                
                        }, failure: { (error: NSError!, errorCode: Int) -> Void in
                            
                    })
                },
                
                failure: {(error:NSError!) -> Void in
                  
            })
        }
    
  
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.Web
        fbLoginManager.logInWithReadPermissions(["email", "public_profile", "user_friends"], handler: {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error == nil && result.token != nil {
                // logged in
            } else {
              
           
                // process error
            }
        })
    }
    
    
    
    
    func didReceiveFacebookProfile(notif:NSNotification){
      if PFUser.currentUser() == nil {
        if FBSDKAccessToken.currentAccessToken() != nil {               // did FB log in or log out?
          
          PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken()).continueWithBlock({
            (task: BFTask!) -> AnyObject! in
            if let user = task.result as? PFUser { 
              if user.isNew {
                
                let smallProfileImage = FBSDKProfile.currentProfile().imagePathForPictureMode(FBSDKProfilePictureMode.Normal, size: CGSizeMake(100, 100))
                let bigProfileImage = FBSDKProfile.currentProfile().imagePathForPictureMode(FBSDKProfilePictureMode.Normal, size: CGSizeMake(600, 600))
                user.username = "\(FBSDKProfile.currentProfile().firstName.lowercaseString)_\(FBSDKProfile.currentProfile().lastName.lowercaseString)"
                user["smallProfileImage"] = "https://graph.facebook.com/\(smallProfileImage)"
                user["bigProfileImage"] = "https://graph.facebook.com/\(bigProfileImage)"
                user["FBID"] = FBSDKProfile.currentProfile().userID
                user["authID"] = "FB" + FBSDKProfile.currentProfile().userID
                
                PFFacebookUtils.linkUserInBackground(user, withAccessToken: FBSDKAccessToken.currentAccessToken()).continueWithBlock({
                  (task: BFTask!) -> AnyObject! in
                  if task.error == nil {
                    // successfully linked user
                    self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
                  } else {
                    switch task.error.code {
                    case 202:
                      let userID = FBSDKProfile.currentProfile().userID
                      user.username?.appendContentsOf(userID.substringWithRange(Range<String.Index>(start: userID.endIndex.advancedBy(-3), end: (userID.endIndex))))
                      PFFacebookUtils.linkUserInBackground(user, withAccessToken: FBSDKAccessToken.currentAccessToken())
                      self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
                    default: break
                    }
                  }
                  return nil
                })
                
              }
              self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
            }
            
            return nil
          })
        } else {
            print("Uh oh. There was an error logging in.")
        }
      
      }
    
      }
    

  
    
    @IBAction func loginWithVkontakte(sender: AnyObject) {
        VKSdk.initializeWithDelegate(self, andAppId: "4991711")
        VKSdk.authorize(["friends", "profile_info", "offline", "wall"])
    }
    

  
  
  

  
  
  
  
  // MARK: - Utility
    func getUsernameifRegistered(ID: String) -> BFTask {
      let task = BFTaskCompletionSource()
        let query = PFUser.query()
        query?.whereKey("authID", equalTo: ID)
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
    
    
    func extendUsernameWithUserIDAndRegister(userID: String, user: PFUser){
        user.username?.appendContentsOf(userID.substringWithRange(Range<String.Index>(start: userID.endIndex.advancedBy(-3), end: (userID.endIndex))))
        user.signUpInBackgroundWithBlock({ (result: Bool, error: NSError?) -> Void in
            if error == nil {
                self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
            }
        })
    }
  
 

}


// MARK: - UITextFieldDelegate
extension LogInVC: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension LogInVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! Cell
    cell.textfield.borderStyle = UITextBorderStyle.None
    cell.label.textColor = UIColor.grayColor()
    
    if tableView == signUpTableView {
      switch indexPath.row {
      case 0:
        cell.label.text = "Email"
        cell.label.font  = UIFont(name: "Nanum Pen", size: cell.label.font.pointSize)
        cell.textfield.tag = 1
        validator.registerField(cell.textfield, rules: [RequiredRule(), EmailRule()])
        return cell
      case 1:
        cell.label.text = "Password"
        cell.label.font  = UIFont(name: "Nanum Pen", size: cell.label.font.pointSize)
        cell.textfield.secureTextEntry = true
        cell.textfield.tag = 2
        validator.registerField(cell.textfield, rules: [RequiredRule(), MinLengthRule(length: 6)])
      case 2:
        cell.label.text = "Username"
        cell.label.font  = UIFont(name: "Nanum Pen", size: cell.label.font.pointSize)
        cell.textfield.placeholder = "optional"
        cell.textfield.tag = 3
        cell.textfield.font = UIFont(name: "Nanum Pen", size: cell.textfield.font!.pointSize)
        return cell
      default :
        break
      }
      return cell
      
    } else {
      switch indexPath.row {
      case 0:
        cell.label.text = "     Email"
        cell.label.font  = UIFont(name: "Nanum Pen", size: cell.label.font.pointSize)
        cell.textfield.tag = 4
        validator.registerField(cell.textfield, rules: [RequiredRule(), EmailRule()])
        return cell
      case 1:
        cell.label.text = "Password"
        cell.label.font  = UIFont(name: "Nanum Pen", size: cell.label.font.pointSize)
        cell.textfield.secureTextEntry = true
        cell.textfield.tag = 5
        cell.textfield.returnKeyType = UIReturnKeyType.Done
        cell.textfield.delegate = self
        validator.registerField(cell.textfield, rules: [RequiredRule(), MinLengthRule(length: 6)])
      default:
        break
      }
      return cell
    }
  }
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == signInTableView {
      return 2
    } else {
      return 3
    }
  }
  
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  
}




// MARK: - ValidationDelegate
extension LogInVC: ValidationDelegate {
  
  
  func validationSuccessful() {
  }
  
  
  
  func validationFailed(errors:[UITextField:ValidationError]) {
    
    let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    
    for (field, _) in validator.errors {
      tempArr.append(field.tag)
    }
    
    if orLabel.text == "or Sign In with:" {
      
      if tempArr.contains(4) {
        alert.title = "Incorrect Email"
        alert.message = "Please check your Email"
        self.presentViewController(alert, animated: true, completion: nil)
        tempArr = [Int]()
        return
      }
      if tempArr.contains(5) {
        alert.title = "Incorrect Password"
        alert.message = "Please check your password"
        self.presentViewController(alert, animated: true, completion: nil)
        tempArr = [Int]()
        return
      }
      signIn()
    } else {
      if tempArr.contains(1) {
        alert.title = "Invalid Email"
        alert.message = "Please check your Email"
        self.presentViewController(alert, animated: true, completion: nil)
        tempArr = [Int]()
        return
      }
      if tempArr.contains(2) {
        alert.title = "Invalid Password"
        alert.message = "Please check your password"
        self.presentViewController(alert, animated: true, completion: nil)
        tempArr = [Int]()
        return
      }
      if tempArr.contains(3) {
        alert.message = "Check your username"
        alert.message = "Please check your username"
        self.presentViewController(alert, animated: true, completion: nil)
        tempArr = [Int]()
        return
      }
      SignUp()
    }
    
    tempArr = [Int]()
  }

  
}



// MARK: - VKSdkDelegate
extension LogInVC: VKSdkDelegate {
  
  func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
    
   if VKSdk.isLoggedIn() {
      let vkReq = VKApi.users().get(["fields" : "photo_100, photo_200_orig"])
      vkReq.executeWithResultBlock({
        (response: VKResponse!) -> Void in
        let json = JSON(response.json)
        if let
          firstName =  json[0]["first_name"].string,
          lastName =   json[0]["last_name"].string,
          userID =     json[0]["id"].number,
          smallPhoto = json[0]["photo_100"].string,
          bigPhoto   = json[0]["photo_200_orig"].string {
          
            self.getUsernameifRegistered("VK\(userID)").continueWithBlock({
              (task: BFTask!) -> AnyObject! in
              if task.error == nil, let username = task.result as? String {
                
                  PFUser.logInWithUsernameInBackground(username, password: "").continueWithBlock({
                    (task: BFTask!) -> AnyObject! in
                    if task.error == nil {
                      self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
                    } else {
                      // process error
                    }
                    return nil
                  })
                
              } else {

                let user = PFUser()
                user.username = "\(firstName)_\(lastName)".lowercaseString
                user.password = ""
                user["authID"] = "VK\(userID)"
                user["VKID"] = "\(userID)"
                user["smallProfileImage"] = smallPhoto
                user["bigProfileImage"] = bigPhoto
                user.signUpInBackground().continueWithBlock({
                  (task: BFTask!) -> AnyObject! in
                  if task.error == nil {
                    self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
                  } else {
                    switch task.error {
                    case 202:   // parse: "username already taken"
                      self.extendUsernameWithUserIDAndRegister("\(userID)", user: user)
                    default: break
                    }
                  }
                  return nil
                })
                
              }
              
              return nil
    
            })
        }
        },  errorBlock: {
          (error: NSError!) -> Void in
         
          })
    }
  }

    
  
  func vkSdkIsBasicAuthorization() -> Bool {
    return false
  }
  
  func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
    VKSdk.getAccessToken()
  }
  
  func vkSdkUserDeniedAccess(authorizationError: VKError!) {
    
  }
  
  func vkSdkShouldPresentViewController(controller: UIViewController!) {
    self.presentViewController(controller, animated: true, completion: nil)
  }
  
  func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
    let vc = VKCaptchaViewController.captchaControllerWithError(captchaError)
    self.presentViewController(vc, animated: true, completion: nil)
  }
  
}



// MARK: - GIDSignInDelegate
extension LogInVC: GIDSignInUIDelegate {
 
  func signInWillDispatch (signIn: GIDSignIn, error: NSError){
    if signIn.hasAuthInKeychain() {
    }
    
  }
  
  
  func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
    viewController.dismissViewControllerAnimated(true, completion: nil)
    if signIn.currentUser != nil {
    
    }
    // performSegueWithIdentifier("did_log_in", sender: nil)
  }

}























