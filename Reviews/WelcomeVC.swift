//
//  LoginVC.swift
//  Reviews
//
//  Created by Admin on 15/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import MediaPlayer
import PureLayout

class WelcomeVC: UIViewController {

    @IBOutlet weak var mainView: UIView!
    
    let registerButton  = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let loginButton  = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
    
    let moviePlayer = MPMoviePlayerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSBundle.mainBundle().loadNibNamed("Welcome", owner: self, options: nil)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let path = NSBundle.mainBundle().pathForResource("welcome_video", ofType:"mp4")
        let url = NSURL.fileURLWithPath(path!)
        moviePlayer.contentURL = url
        moviePlayer.view.frame = self.view.bounds
        moviePlayer.scalingMode = MPMovieScalingMode.AspectFill
        moviePlayer.controlStyle = .None
        moviePlayer.prepareToPlay()
        moviePlayer.repeatMode = MPMovieRepeatMode.One
        self.view.addSubview(moviePlayer.view)
    
        
        registerButton.frame = CGRectMake(100, 100, 100, 50)
        registerButton.backgroundColor = UIColor.greenColor()
        registerButton.setTitle("Register", forState: UIControlState.Normal)
        registerButton.addTarget(self, action: "registerButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(registerButton)
       
        
        loginButton.frame = CGRectMake(100, 100, 100, 50)
        loginButton.backgroundColor = UIColor.greenColor()
        loginButton.setTitle("Login", forState: UIControlState.Normal)
        loginButton.addTarget(self, action: "loginButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginButton)
        
        
        registerButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Bottom, ofView: self.view, withOffset: -10.0)
        registerButton.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Left, ofView: self.view, withOffset: 10.0)
        registerButton.autoSetDimension(ALDimension.Height, toSize: self.view.bounds.height/16)
        registerButton.autoConstrainAttribute(ALAttribute.Width, toAttribute: ALAttribute.Width, ofView: loginButton)
       
    
       loginButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Bottom, ofView: self.view, withOffset: -10.0)
       loginButton.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Right, ofView: self.view, withOffset: -10.0)
       loginButton.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: registerButton, withOffset: 10.0)
       loginButton.autoSetDimension(ALDimension.Height, toSize: self.view.bounds.height/16)
       loginButton.autoConstrainAttribute(ALAttribute.Width, toAttribute: ALAttribute.Width, ofView: registerButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func loginButtonAction(sender: UIButton!){
        performSegueWithIdentifier("log_in", sender: nil)
    }
    
    func registerButtonAction(sender:UIButton!)
    {
        performSegueWithIdentifier("register", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "log_in" {
            let vc = segue.destinationViewController as? Log_inVC
        }
         else if segue.identifier == "register" {
                let vc = segue.destinationViewController as? RegisterVC
            }
        }
    
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        moviePlayer.currentPlaybackTime = 0
        moviePlayer.pause()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        moviePlayer.play()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
