//
//  Login.swift
//  Reviews
//
//  Created by Mikhail Yakushin on 17/07/15.
//  Copyright (c) 2015 Mikhail Yakushin. All rights reserved.
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
//import FontBlaster
import Parse
import ParseFacebookUtilsV4
import Async
import SwiftyTimer
import Bolts

class LogInVC: UIViewController {
   
  @IBOutlet weak var backgroundImage: UIImageView!
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
 
//    @IBAction func loginWithGoogle(sender: AnyObject) {
//    GIDSignIn.sharedInstance().allowsSignInWithBrowser = false
//    GIDSignIn.sharedInstance().uiDelegate = self
//    GIDSignIn.sharedInstance().clientID = "1095542523991-7s9j46knl20bhge5ggv6ctbn0be6bf0f.apps.googleusercontent.com"
//    GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
//    GIDSignIn.sharedInstance().signIn()
//  }
    
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
    
    override func viewDidLoad() {
      super.viewDidLoad()
    //  FontBlaster.blast()
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
      
   // shareThoughtsLabel.text = "Sign In \n  and start sharing your thoughts"
  //  shareThoughtsLabel.font = UIFont(name: "Nanum Pen", size: shareThoughtsLabel.font.pointSize)
//    shareThoughtsLabel.numberOfLines = 0
    
      signInTriangle.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
      signUpTriangle.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
      signUpTriangle.hidden = true
    
    
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "instagramLoginWebViewWillDisappear:", name: "instagramLoginWebViewWillDisappear", object: nil)
      
//    let path = NSBundle.mainBundle().pathForResource("loginBackground", ofType: "pdf")
//    backgroundImage.image = UIImage(contentsOfFile: path!)
      
      UserSingleton.getSharedInstance().loginLoadingStateDelegate = self
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
  
  func signUpTableViewUserInteraction(condition: Bool) {
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
    
  // TODO: Move to Model
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
                  UserSingleton.getSharedInstance().checkUserLinkedAccounts()
                  if FBSDKAccessToken.currentAccessToken() != nil && FBSDKProfile.currentProfile() == nil {
                    NSNotificationCenter.defaultCenter().addObserver(self, name: FBSDKProfileDidChangeNotification, object: nil, handler: { (observer, notification) -> Void in
                      BFTask(forCompletionOfAllTasks: [LinkedAccount.updateAll(), UserSingleton.getSharedInstance().loadLinkedAccountsFriends()])
                        .continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
                        self.pushMainVC()
                        return nil
                      })
                    })
                  } else {
                    BFTask(forCompletionOfAllTasks: [LinkedAccount.updateAll(), UserSingleton.getSharedInstance().loadLinkedAccountsFriends()])
                    .continueWithSuccessBlock({ (task: BFTask) -> AnyObject? in
                      self.pushMainVC()
                      return nil
                    })
                  }
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
    
    func signUp(){
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
            UserSingleton.getSharedInstance()
            self.pushMainVC()
          }
        } else {
          switch task.error!.code {
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
              self.pushMainVC()
          } else {
        
          }
      }
  }
  
  @IBAction func loginWithInstagram(sender: AnyObject) {
    UserSingleton.getSharedInstance().loginWithInstagram()
  }

  @IBAction func loginWithFacebook(sender: AnyObject) {
    UserSingleton.getSharedInstance().loginWithFacebook()
  }
  
  @IBAction func loginWithVkontakte(sender: AnyObject) {
    UserSingleton.getSharedInstance().loginWithVkontakte()
  }
  
  func pushMainVC() {
    let mainTabBarVC = self.storyboard!.instantiateViewControllerWithIdentifier("main") as! UITabBarController
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    mainTabBarVC.view.layoutIfNeeded()
    UIView.transitionFromView((appDelegate.window?.rootViewController?.view)!,
      toView: mainTabBarVC.view,
      duration: 0.5,
      options: UIViewAnimationOptions.TransitionCrossDissolve,
      completion: { (_) -> Void in
        appDelegate.window?.rootViewController? = mainTabBarVC
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
  
  
//  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//    return 1
//  }

  
}


// MARK: - Validation Delegate
extension LogInVC: ValidationDelegate {
  
  func validationSuccessful() {
    if orLabel.text == "or Sign In with:" {
      signIn()
    } else {
      signUp()
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
      signUp()
    }
    
    tempArr = [Int]()
  }

  
}



extension LogInVC: LoadingStateDelegate {
  
  func didEndNetworingActivity() {
    if let loadingView = self.view.viewWithTag(LoadingIndicatorViewTag) as? LoadingIndicatorView {
      loadingView.toggleTickWithTimeIntervalExpirationBlock({ () -> Void in
          self.pushMainVC()
      })
    } else {
      let loadingStateView = LoadingIndicatorView()
      self.view.addSubview(loadingStateView)
      NSTimer.after(0.5.second) {
        loadingStateView.toggleTickWithTimeIntervalExpirationBlock({ () -> Void in
          self.pushMainVC()
        })
      }
    }
  }
  
}













// MARK: - GIDSignInDelegate
//extension LogInVC: GIDSignInUIDelegate {
// 
//  func signInWillDispatch (signIn: GIDSignIn, error: NSError){
//    if signIn.hasAuthInKeychain() {
//      
//    }
//    
//  }
//  
//  func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
//    viewController.dismissViewControllerAnimated(true, completion: nil)
//    if signIn.currentUser != nil {
//    
//    }
//    // self.pushMainVC()
//  }
//
//}







