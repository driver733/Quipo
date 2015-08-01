//
//  Login.swift
//  Reviews
//
//  Created by Admin on 17/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
//import TwitterKit
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









class Log_inVC: UIViewController, UITableViewDataSource, UITableViewDelegate, VKSdkDelegate, ValidationDelegate, UITextFieldDelegate
    
//,GIDSignInUIDelegate
{
   
    @IBOutlet weak var tableView_sign_in: UITableView!
    @IBOutlet weak var tableView_sign_up: UITableView!
    @IBOutlet weak var sign_in_or_up: UIButton!
    @IBOutlet weak var OR_label: UILabel!
    @IBOutlet weak var signIn_button: UIButton!
    @IBOutlet weak var signUp_button: UIButton!
    @IBOutlet weak var share_thoughts_label: UILabel!
    @IBOutlet weak var signUp_triangle: UIView!
    @IBOutlet weak var signIn_triangle: UIView!
    
    
    @IBOutlet weak var fb: UIButton!
    @IBOutlet weak var vk: UIButton!
    @IBOutlet weak var i: UIButton!
    @IBOutlet weak var g: UIButton!
    @IBOutlet weak var t: UIButton!
    
    

    @IBAction func didLogOut(segue: UIStoryboardSegue) {
       
    }
    
    @IBAction func signUp_button(sender: AnyObject) {
        tableView_sign_in.hidden = true
        tableView_sign_up.hidden = false
        signUp_triangle.hidden = false
        signIn_triangle.hidden = true
        OR_label.text = "or Sign Up with:"
        share_thoughts_label.text = "Sign Up \n and start sharing your thoughts"
        
        
        
    //    share_thoughts_button.setTitle("Sign Up \n and start sharing your thoughts", forState: UIControlState.Normal)
        
        /*
        let paths = tableView_sign_in.visibleCells()
        for cell in tableView_sign_in.visibleCells()  {
            if let customCell as? tempCell {
                customCell.textField.enabled = false
            }
        }
*/
        
        for var section = 0; section < tableView_sign_in.numberOfSections; ++section {
            for var row = 0; row < tableView_sign_in.numberOfRowsInSection(section); ++row {
                let cellPath = NSIndexPath(forRow: row, inSection: section)
                let sign_in_cell: tempCell = tableView_sign_in.cellForRowAtIndexPath(cellPath) as! tempCell
                sign_in_cell.textfield.userInteractionEnabled = false
         
            }
        }
        
        
        
        for var section = 0; section < tableView_sign_up.numberOfSections; ++section {
            for var row = 0; row < tableView_sign_up.numberOfRowsInSection(section); ++row {
                let cellPath = NSIndexPath(forRow: row, inSection: section)
                let sign_up_cell: tempCell = tableView_sign_up.cellForRowAtIndexPath(cellPath) as! tempCell
                sign_up_cell.textfield.userInteractionEnabled = true
            
            }
        }
        
        
        
        
    }
    @IBAction func signIn_button(sender: AnyObject) {
        tableView_sign_up.hidden = true
        tableView_sign_in.hidden = false
        signUp_triangle.hidden = true
        signIn_triangle.hidden = false
        OR_label.text = "or Sign In with:"
     //   share_thoughts_button.setTitle("Sign In \n and start sharing your thoughts", forState: UIControlState.Normal)
        share_thoughts_label.text = "Sign In \n and start sharing your thoughts"
        
        
        
        for var section = 0; section < tableView_sign_in.numberOfSections; ++section {
            for var row = 0; row < tableView_sign_in.numberOfRowsInSection(section); ++row {
                let cellPath = NSIndexPath(forRow: row, inSection: section)
                let sign_in_cell: tempCell = tableView_sign_in.cellForRowAtIndexPath(cellPath) as! tempCell
                sign_in_cell.textfield.userInteractionEnabled = true
            }
        }
        
        
        
        for var section = 0; section < tableView_sign_up.numberOfSections; ++section {
            for var row = 0; row < tableView_sign_up.numberOfRowsInSection(section); ++row {
                let cellPath = NSIndexPath(forRow: row, inSection: section)
                let sign_up_cell: tempCell = tableView_sign_up.cellForRowAtIndexPath(cellPath) as! tempCell
                sign_up_cell.textfield.userInteractionEnabled = false
            }
        }

        
        
    }
    
    @IBAction func login_start(sender: AnyObject) {
        validator.validate(self)
    }
    
    
    let validator = Validator()
    var tempArr: [Int] = [Int]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var textArray: NSMutableArray! = NSMutableArray()
    var vkontakteAcessToken: VKAccessToken? = nil
    var facebookAcessToken: String? = nil
    var googleAccessToken: String? = nil
    
    
    let instagramKeychain = Keychain(server: "https://api.instagram.com/oauth/authorize", protocolType: .HTTPS, authenticationType: .HTMLForm)
    let vkontakteKeychain = Keychain(server: "https://oauth.vk.com/authorize", protocolType: .HTTPS, authenticationType: .HTMLForm)
    
    
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        FontBlaster.blast()
        FontBlaster.debugEnabled = true
        NSBundle.mainBundle().loadNibNamed("Log_in", owner: self, options: nil)
        
        tableView_sign_in.registerNib(UINib(nibName: "tempCell", bundle: nil), forCellReuseIdentifier: "tempCell")
        tableView_sign_in.delegate = self
        tableView_sign_in.dataSource = self
        tableView_sign_in.rowHeight = UITableViewAutomaticDimension;
        tableView_sign_in.estimatedRowHeight = 44.0;
        
        tableView_sign_up.registerNib(UINib(nibName: "tempCell", bundle: nil), forCellReuseIdentifier: "tempCell")
        tableView_sign_up.delegate = self
        tableView_sign_up.dataSource = self
        tableView_sign_up.rowHeight = UITableViewAutomaticDimension;
        tableView_sign_up.estimatedRowHeight = 44.0;
        tableView_sign_up.hidden = true
    
   
        OR_label.font = UIFont(name: "Nanum Pen", size: OR_label.font.pointSize)
        signIn_button.titleLabel?.font = UIFont(name: "Nanum Pen", size: signIn_button.titleLabel!.font.pointSize)
        signUp_button.titleLabel?.font = UIFont(name: "Nanum Pen", size: signUp_button.titleLabel!.font.pointSize)
  
        sign_in_or_up.titleLabel?.font = UIFont(name: "Nanum Pen", size: signUp_button.titleLabel!.font.pointSize)
        
        share_thoughts_label.text = "Sign In \n  and start sharing your thoughts"
        share_thoughts_label.font = UIFont(name: "Nanum Pen", size: share_thoughts_label.font.pointSize)
        share_thoughts_label.numberOfLines = 0
        

        
        for var section = 0; section < tableView_sign_up.numberOfSections; ++section {
            for var row = 0; row < tableView_sign_up.numberOfRowsInSection(section); ++row {
                let cellPath = NSIndexPath(forRow: row, inSection: section)
                let sign_up_cell: tempCell = tableView_sign_up.cellForRowAtIndexPath(cellPath) as! tempCell
            }
        }

    //    let triangle = Triangle(frame: CGRectMake(signUp_button.frame.origin.x, signUp_button.frame.origin.y, 30, 20))
      //  triangle.backgroundColor = .clearColor()
     //   view.addSubview(triangle)
        
        
    signIn_triangle.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
    signUp_triangle.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
    signUp_triangle.hidden = true
        
        
        
        
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
        
       //     currentUser!.setObject(FBSDKAccessToken.currentAccessToken().tokenString, forKey: "facebookID")
       //     currentUser!.saveInBackground()
           
        } else {
            // Show the signup or login screen
        }
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    
    
    
    
    func validationSuccessful() {
        //  performSegueWithIdentifier("did_log_in", sender: nil)
        print("success")
    }
    
    
    
    
    
    
    func validationFailed(errors:[UITextField:ValidationError]) {
        
        var alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        for (field, error) in validator.errors {
            tempArr.append(field.tag)
        }
        
        if OR_label.text == "or Sign In with:" {

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
        }
            
        else  {
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

    
 
    
    func signIn(){
        var alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        var username = ""
        let email = (tableView_sign_in.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! tempCell).textfield.text
        let password = (tableView_sign_in.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! tempCell).textfield.text
        var query = PFUser.query()
        query?.whereKey("email", equalTo: email!)
        query?.findObjectsInBackgroundWithBlock({ (foundUsers: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
             if let foundUsers = foundUsers as? [PFObject] {
                if foundUsers.count == 1 {
                    for user in foundUsers {
                        username = (user as! PFUser).username!
                    }
                }
              }
            }
            
            PFUser.logInWithUsernameInBackground(
                username,
                password: (self.tableView_sign_in.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! tempCell).textfield.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    if user != nil {
                        self.performSegueWithIdentifier("did_log_in", sender: nil)
                    } else {
                        switch error!.code {
                        case 101:
                            alert.title = "Incorrect Email or Password"
                            alert.message = "Please check your Email and Password!"
                            self.presentViewController(alert, animated: true, completion: nil)
                    
                        default: break
                        }
                        
                        }
            }
            
        })
        
     
        
        
       
    }
    
    
    func SignUp(){
        var user = PFUser()
        
        var alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        if !(tableView_sign_up.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! tempCell).textfield.text!.isEmpty {
            user.username = (tableView_sign_up.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! tempCell).textfield.text
        }
        else {
//let arr = split((tableView_sign_up.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! tempCell).textfield.text) {$0 == "@"}
            let arr: Array = ((tableView_sign_up.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! tempCell).textfield.text?.componentsSeparatedByString("@"))!
         user.username = arr[0]
        }

        
        user.password = (tableView_sign_up.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! tempCell).textfield.text
        user.email = (tableView_sign_up.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! tempCell).textfield.text
        
        // other fields can be set just like with PFObject
      
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if error == nil {
                // signed up!
            }
                else if let error = error {
                switch error.code {
                case 202:
                    alert.title = "Username already taken"
                    alert.message = "This username is already taken. Please use a different one."
                    self.presentViewController(alert, animated: true, completion: nil)
                default: break
                }
                
                
                
            }
        }
        
    }
    
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tempCell", forIndexPath: indexPath) as! tempCell
        cell.textfield.borderStyle = UITextBorderStyle.None
        cell.label.textColor = UIColor.grayColor()
        
        if tableView == tableView_sign_up {
            switch indexPath.row {
            case 0:
                cell.label.text = "     Email"
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

        }
        else {
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
        default :
            break
        }
        return cell
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView_sign_in {
            return 2
        }
        else {
            return 3
        }
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func next(){
        performSegueWithIdentifier("did_log_in", sender: nil)
    }
    
    
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "did_log_in" {
           
        }
    }
    */
    
    
    
 /*
    
    
    @IBAction func loginWithGoogle(sender: AnyObject) {
        GIDSignIn.sharedInstance().allowsSignInWithBrowser = false
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "1095542523991-7s9j46knl20bhge5ggv6ctbn0be6bf0f.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().signIn()

    }
    
    
    
 
    func signInWillDispatch (signIn: GIDSignIn, error: NSError){
        if signIn.hasAuthInKeychain() {
        //self.testLoginLabel.text = signIn.currentUser.profile.name
        }

    }
    
    
    
    func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
        
        viewController.dismissViewControllerAnimated(true, completion: nil)
        
          if signIn.currentUser != nil {
            println(signIn.currentUser.profile.name)
         }
       // performSegueWithIdentifier("did_log_in", sender: nil)
    }

    
    
    */

    
    @IBAction func buttonTwitterLogin(sender: AnyObject) {
        
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                self.performSegueWithIdentifier("did_log_in", sender: nil)
            } else {
                print("Uh oh. The user cancelled the Twitter login.")
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
        self.view.opaque = false
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        if let at = self.instagramKeychain.get("access_token"){
            let url :String = "https://api.instagram.com/v1/users/self/?access_token=\(at)"
            let parameters :Dictionary = Dictionary<String, AnyObject>()
            auth.client.get(url, parameters: parameters,
                success: {
                    data, response in
                    let json = JSON(data: data)
                     
                    // println(json)
                }, failure: {(error:NSError!) -> Void in
                    print(error)
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
                    print(error.localizedDescription)
            })
        }
    }
    
    func getfbFriendList(user: PFUser){
   
    }
    
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        
    let fbLoginManager = FBSDKLoginManager()
    fbLoginManager.loginBehavior = FBSDKLoginBehavior.Web
    fbLoginManager.logInWithReadPermissions(["email", "public_profile", "user_friends"], handler: {
        (result: FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
        if error == nil && result.token != nil {
            PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken(), block: {
                    (user: PFUser?, error: NSError?) -> Void in
                    if user != nil {
                    self.performSegueWithIdentifier("did_log_in", sender: nil)
                    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: nil)
                        graphRequest.startWithCompletionHandler({
                            (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                            if error == nil {
                                let json = JSON(result)
                                print(json)
                                if let fbID = json["data"][0]["id"].string {
                                  // friends who have installed the Moviethete
                                }
                            }
                            else {
                                // process error
                            }
                        })

                    }
                    else {
                        print("Uh oh. There was an error logging in.")
                    }
                })
        }
        else {
            // process error
        }
    })
        
    }
    
    
    @IBAction func loginWithVkontakte(sender: AnyObject) {
        VKSdk.initializeWithDelegate(self, andAppId: "4991711")
        if VKSdk.wakeUpSession() {
        }
        else {
            VKSdk.authorize(["friends", "profile_info", "offline", "wall"])
        }
        
        if VKSdk.isLoggedIn() {
            let user = PFUser()
            
            let vkReq = VKApi.users().get()
            vkReq.executeWithResultBlock({
            response in
                let json = JSON(response.json)
                if let firstName = json[0]["first_name"].string, let lastName = json[0]["last_name"].string {
                    let username: String = firstName + "_" + lastName
                    user.username = username.lowercaseString
                    self.performSegueWithIdentifier("did_log_in", sender: nil)
                }
    
                },  errorBlock: {(error:NSError!) -> Void in
                    print(error.localizedDescription)
            })
            
          //  user.username = V
            /*
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if error == nil {
                    self.performSegueWithIdentifier("did_log_in", sender: nil)
                }
                
                
            }
            */
        }
        
        /*
           // let audioReq: VKRequest = VKRequest(method: "friends.getAppUsers", andParameters: nil, andHttpMethod: "GET")
        let audioReq = VKApi.users().get()
            audioReq.executeWithResultBlock({
                response in
                let json = JSON(response.json)
                for (key, subJson) in json[0] {
                    if let title = subJson[key].string {
                        println(title)
                    }
                }
           //     println("//////////////////")
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
                //    println("ID - FAIL!")
                }
                println(response.json)
                },
                errorBlock: {(error:NSError!) -> Void in
                    println(error.localizedDescription)
            })
        */
        
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
        self.vkontakteAcessToken = newToken
    }
    
    func vkSdkIsBasicAuthorization() -> Bool {
        return true
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
        vc.presentIn(self)
    }
    
    
    
    
    
  
    
    
    
 

}
