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
import Async

let DID_LOG_IN_SEGUE_IDENTIFIER = "didLogIn"

class LogInVC: UIViewController {
   
  @IBOutlet weak var signInTableView: UITableView!
  @IBOutlet weak var signUpTableView: UITableView!
  @IBOutlet weak var signInOrUp: UIButton!
  @IBOutlet weak var orLabel: UILabel!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var signUpTriangle: UIView!
  @IBOutlet weak var signInTriangle: UIView!
  
  
  var loginActivityIndicator: UIActivityIndicatorView!
  let loginActivityIndicatorBackgroundView = UIView()
  let validator = Validator()
  var tempArr: [Int] = [Int]()
  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  var textArray: NSMutableArray! = NSMutableArray()
  
  
    
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
      signInOrUp.setTitle("Sign Up", forState: .Normal)
    }
  
    @IBAction func signInButton(sender: AnyObject) {
      signUpTableView.hidden = true
      signInTableView.hidden = false
      signUpTableViewUserInteraction(false)
      signInTableViewUserInteraction(true)
      signUpTriangle.hidden = true
      signInTriangle.hidden = false
      orLabel.text = "or Sign In with:"
      signInOrUp.setTitle("Sign In", forState: .Normal)
    }
    
    @IBAction func startLogin(sender: AnyObject) {
        validator.validate(self)
    }
    
  
  
  
    

  
  override func viewWillAppear(animated: Bool) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFacebookProfile:", name: FBSDKProfileDidChangeNotification, object: nil)
  }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      FontBlaster.blast()
      NSBundle.mainBundle().loadNibNamed("LogIn", owner: self, options: nil)
      self.navigationController?.navigationBarHidden = true
      self.hidesBottomBarWhenPushed = true
      
      signInTableView.registerNib(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "Cell")
      signInTableView.rowHeight = UITableViewAutomaticDimension;
      signInTableView.estimatedRowHeight = 44.0;
      
      signUpTableView.registerNib(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "Cell")
      signUpTableView.rowHeight = UITableViewAutomaticDimension;
      signUpTableView.estimatedRowHeight = 44.0;
      signUpTableView.hidden = true
  
      orLabel.font = UIFont(name: "Nanum Pen", size: orLabel.font.pointSize)
      signInButton.titleLabel?.font = UIFont(name: "Nanum Pen", size: signInButton.titleLabel!.font.pointSize)
      signUpButton.titleLabel?.font = UIFont(name: "Nanum Pen", size: signUpButton.titleLabel!.font.pointSize)

      signInOrUp.titleLabel?.font = UIFont(name: "Nanum Pen", size: signUpButton.titleLabel!.font.pointSize)
      
   //   shareThoughtsLabel.text = "Sign In \n  and start sharing your thoughts"
  //    shareThoughtsLabel.font = UIFont(name: "Nanum Pen", size: shareThoughtsLabel.font.pointSize)
//      shareThoughtsLabel.numberOfLines = 0
    
      signInTriangle.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
      signUpTriangle.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
      signUpTriangle.hidden = true
    
      FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "instagramLoginWebViewWillDisappear:", name: "instagramLoginWebViewWillDisappear", object: nil)
      
  }
  
  
  func instagramLoginWebViewWillDisappear(notif: NSNotification) {
    startLoginActivityIndicator()
  }
  
  
  func startLoginActivityIndicator() {
    loginActivityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 10, 10)) as UIActivityIndicatorView
    loginActivityIndicatorBackgroundView.frame = self.view.frame
    loginActivityIndicatorBackgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    loginActivityIndicatorBackgroundView.center = self.view.center
    loginActivityIndicator.center = self.view.center
    loginActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    loginActivityIndicatorBackgroundView.addSubview(loginActivityIndicator)
    self.view.addSubview(loginActivityIndicatorBackgroundView)
    loginActivityIndicator.startAnimating()
  }
  
  func stopLoginActivityIndicator() {
    if loginActivityIndicator != nil {
      loginActivityIndicator.stopAnimating()
      loginActivityIndicator.removeFromSuperview()
      loginActivityIndicatorBackgroundView.removeFromSuperview()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    NSNotificationCenter.defaultCenter().removeObserver(self)
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
        user["smallProfileImage"] = "https://graph.facebook.com/133559250332613/picture?type=normal&width=100&height=100"
        user["bigProfileImage"] = "https://graph.facebook.com/133559250332613/picture?type=normal&width=600&height=600"
        user.signUpInBackground().continueWithBlock {
          (task: BFTask!) -> AnyObject! in
          if task.error == nil {
            Async.main {
              self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
            }
          } else {
            switch task.error.code {
            case 202:
              alert.title = "Username already taken"   // "Or email is already taken. Have trouble logging in? " -> Needs to take into account email too.
              alert.message = "This username is already taken. Please use a different one."
              Async.main {
                self.presentViewController(alert, animated: true, completion: nil)
              }
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
      UserSingelton.sharedInstance.loginWithInstagram().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        self.stopLoginActivityIndicator()
        self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
        return nil
      }
    }
    
  
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
      let fbLoginManager = FBSDKLoginManager()
      fbLoginManager.logInWithReadPermissions(["email", "public_profile", "user_friends"],
        fromViewController: self,
        handler: {
          (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
          if error == nil && result.token != nil {
            // logged in
          } else {
        
            // process error
          }
      })
    }
    
    
    
    
  func didReceiveFacebookProfile(notif: NSNotification){
    startLoginActivityIndicator()
    NSNotificationCenter.defaultCenter().removeObserver(self, name: FBSDKProfileDidChangeNotification, object: nil)
    UserSingelton.sharedInstance.didReceiveFacebookProfile().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      Async.main {
        self.stopLoginActivityIndicator()
      }
      self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
      return nil
    }
  }
  
    
    @IBAction func loginWithVkontakte(sender: AnyObject) {
        VKSdk.initializeWithDelegate(self, andAppId: "4991711")
        VKSdk.authorize(["friends", "profile_info", "offline", "wall"])
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




// MARK: - Validation Delegate
extension LogInVC: ValidationDelegate {
  
  
  func validationSuccessful() {
    if orLabel.text == "or Sign In with:" {
      signIn()
    } else {
      SignUp()
    }
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
    self.startLoginActivityIndicator()
    UserSingelton.sharedInstance.didReceiveNewVKToken().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
      self.stopLoginActivityIndicator()
      self.performSegueWithIdentifier(DID_LOG_IN_SEGUE_IDENTIFIER, sender: nil)
      return nil
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























