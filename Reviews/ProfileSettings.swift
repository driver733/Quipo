//
//  ProfileSettings.swift
//  Moviethete
//
//  Created by Mike on 8/1/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import Parse
import VK_ios_sdk

class ProfileSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "profileSettingsCell", bundle: nil), forCellReuseIdentifier: "profileSettingsCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 44.0;
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    /*
    @IBAction func segu goToRoot: UIStoryboardSegue segue {
   //  @IBAction func signUp_button(sender: AnyObject) {
   
    }
    */
    
    
    /*
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        
    }
    */
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("profileSettingsCell", forIndexPath: indexPath) as! profileSettingsCell
        
        if indexPath.row == 0 {
            cell.tempLabel.text = "Log Out"
        }
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.row == 0 {
            PFUser.logOutInBackground()
            VKSdk.forceLogout()
            performSegueWithIdentifier("didLogOut", sender: nil)
        }
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
