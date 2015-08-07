//
//  ProfileVC.swift
//  Reviews
//
//  Created by Admin on 29/06/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import OAuthSwift
import SwiftyJSON
import VK_ios_sdk
import InstagramKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import KeychainAccess
//import FontBlaster
import TLYShyNavBar







class ProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
   
    @IBOutlet weak var tableView: UITableView!
    
      var textArray: NSMutableArray! = NSMutableArray()
      var str = ""
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /*
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
        cell.userName.text = "Dachnik"
        let url = NSURL(string: "http://da4nikam.ru/wp-content/uploads/2010/12/e5_1_b.jpg")
        cell.userImage.setImageWithUrl(url!, placeHolderImage: nil)
        */
        
            if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileTopCell", forIndexPath: indexPath) as! ProfileTopCell
            cell.awaitedView.layer.cornerRadius = 8
            cell.awaitedView.layer.masksToBounds = true
            cell.followersView.layer.cornerRadius = 8
            cell.followersView.layer.masksToBounds = true
            cell.followingView.layer.cornerRadius = 8
            cell.followingView.layer.masksToBounds = true
            cell.favouriteView.layer.cornerRadius = 8
            cell.favouriteView.layer.masksToBounds = true
            cell.watchedView.layer.cornerRadius = 8
            cell.watchedView.layer.masksToBounds = true
            cell.unknownView.layer.cornerRadius = 8
            cell.unknownView.layer.masksToBounds = true
            
            
            cell.selectionStyle = .None
            
            return cell
       }
       else {
        
            if str == "reviews" {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileUserReviews", forIndexPath: indexPath) as! ProfileUserReviews
        cell.movieName.text = "Titanic"
        cell.userReview.text = "Кино"
        cell.posterImage.sd_setImageWithURL(NSURL(string: "http://www.freemovieposters.net/posters/titanic_1997_6121_poster.jpg"), placeholderImage: getImageWithColor(.grayColor(), size: cell.posterImage.bounds.size))
        return cell

            } else {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
        cell.userName.text = "Dachnik"
                            
            
        
        cell.profileImage.sd_setImageWithURL(NSURL(string: "http://da4nikam.ru/wp-content/uploads/2010/12/e5_1_b.jpg"), placeholderImage: getImageWithColor(.grayColor(), size: cell.profileImage.bounds.size))
                if let cellImage = cell.profileImage.image {
                    cell.profileImage.image = Toucan(image: cellImage).maskWithEllipse().image
                }
           return cell
            }
        
        
        
       }

       
    }
    
    
    
    
  //   UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    
   
    
    
 
    
    
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return 20
    }
    
    
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
  /*
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.alpha = 0
        return view
    }
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
      
        
          tableView.registerNib(UINib(nibName: "ProfileTopCell", bundle: nil), forCellReuseIdentifier: "ProfileTopCell")
          tableView.registerNib(UINib(nibName: "ProfileUserReviews", bundle: nil), forCellReuseIdentifier: "ProfileUserReviews")   
          tableView.registerNib(UINib(nibName: "ProfileFollowerCell", bundle: nil), forCellReuseIdentifier: "ProfileFollowerCell")
          tableView.delegate = self
          tableView.dataSource = self
          tableView.rowHeight = UITableViewAutomaticDimension;
          tableView.estimatedRowHeight = 44.0;
     
          shyNavBarManager.scrollView = self.tableView
        
        
        
          //      self.automaticallyAdjustsScrollViewInsets = false
        
        
        
        
         let gesture = UITapGestureRecognizer(target: self, action: "cellPressed:")
         self.view.addGestureRecognizer(gesture)
         gesture.cancelsTouchesInView = false
        
        
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: "settings:")
        
        
       
        
    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profileSettings" {
           
        }
    }
    */
    
    func settings(sender: UIBarButtonItem) {
        performSegueWithIdentifier("profileSettings", sender: nil)
    }
    
    
    
    
    func cellPressed(press: UITapGestureRecognizer) {
        
        if press.state == .Ended {
            let location = press.locationInView(tableView)
            let path = tableView.indexPathForRowAtPoint(location)
            if path!.row == 0 {
                let newCell: ProfileTopCell = tableView.cellForRowAtIndexPath(path!) as! ProfileTopCell
                
                
                var viewPoint = newCell.awaitedView.convertPoint(location, fromView: tableView)
                if newCell.awaitedView.pointInside(viewPoint, withEvent: nil){
                    
                    
                    str = "reviews"
                    tableView.reloadData()
                    
                }
                
                viewPoint = newCell.favouriteView.convertPoint(location, fromView: tableView)
                if newCell.favouriteView.pointInside(viewPoint, withEvent: nil){
                    
                    str = ""
                    tableView.reloadData()
                }
                
                viewPoint = newCell.watchedView.convertPoint(location, fromView: tableView)
                if newCell.watchedView.pointInside(viewPoint, withEvent: nil){
                }
                
                viewPoint = newCell.followingView.convertPoint(location, fromView: tableView)
                if newCell.followingView.pointInside(viewPoint, withEvent: nil){
                }
                
                viewPoint = newCell.followersView.convertPoint(location, fromView: tableView)
                if newCell.followersView.pointInside(viewPoint, withEvent: nil){
                }
                
                viewPoint = newCell.unknownView.convertPoint(location, fromView: tableView)
                if newCell.unknownView.pointInside(viewPoint, withEvent: nil){
                }
                
                
            }
            
            
        }

        
    }
    

    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    

    

    

}
