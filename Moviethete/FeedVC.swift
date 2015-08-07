//
//  FirstViewController.swift
//  Reviews
//
//  Created by Admin on 17/06/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import TLYShyNavBar
import Async
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Parse
import SDWebImage

extension UIViewController {
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


class FeedVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var arrayOfPosts: [Post] = [Post]()
    var fbProfile = false
    
    override func viewDidLoad() {
         super.viewDidLoad()
         tableView.registerNib(UINib(nibName: "TopCell", bundle: nil), forCellReuseIdentifier: "TopCell")
         tableView.registerNib(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")
         tableView.delegate = self
         tableView.dataSource = self
         tableView.rowHeight = UITableViewAutomaticDimension;
         tableView.estimatedRowHeight = 44.0;
         setUpPost()
         shyNavBarManager.scrollView = self.tableView;
    }
    
    
    

    
    // This function will be called when the Dynamic Type user setting changes (from the system Settings app)
    func contentSizeCategoryChanged(notification: NSNotification)
    {
        tableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setUpPost(){
        let post1 = Post(userName: "Dachnik", timeSincePosted: "two hours ago", profileImage: nil, posterImage: nil)
        for var i = 0; i < 200; i++ {
        arrayOfPosts.append(post1)
        }
        
    }
    
    func fb(notif: NSNotification) {
        fbProfile = true
        tableView.reloadData()
    }
  
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailedPost" {
            if let vc = segue.destinationViewController as? DetailedPostVC {
                    vc.num = tableView.indexPathForSelectedRow!.row
            }
        }
    }
    
}





// MARK: - UITableViewDelegate, UITableViewDataSource
extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        _ = arrayOfPosts.count;
        /*
        if (indexPath.row == 0)
        {
        let cell:TopCell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopCell
        cell.userName.text = "Loading..."
        }
        else
        {
        // Leave cells empty if there's no data yet
        if (nodeCount > 0)
        {
        */
        if (indexPath.row % 2 == 0){
            // Set up the cell representing the app
            let cell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopCell
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
            let post = arrayOfPosts[indexPath.row]
            cell.userName.text = post.userName
            cell.timeSincePosted.text = post.timeSincePosted
            // Only load cached images; defer new downloads until scrolling ends
            // if (post.profileImage == nil)
            // {
            if (!tableView.dragging && !tableView.decelerating)
            {
                cell.profileImage.sd_setImageWithURL(
                    NSURL(string: PFUser.currentUser()!.objectForKey("smallProfileImage") as! String),
                    placeholderImage: getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.bounds.size),
                    options: SDWebImageOptions.RefreshCached, completed:{(
                        image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                        cell.profileImage.image = Toucan(image: image).maskWithEllipse().image
                })
                return cell
            }
            return cell
        }
        // Set up the cell representing the app
        let cell = tableView.dequeueReusableCellWithIdentifier("ContentCell", forIndexPath: indexPath) as! ContentCell
        _ = arrayOfPosts[indexPath.row]
        if (!tableView.dragging && !tableView.decelerating)
        {
            cell.posterImage.sd_setImageWithURL(NSURL(string: "http://www.freemovieposters.net/posters/titanic_1997_6121_poster.jpg")!, placeholderImage: getImageWithColor(.grayColor(), size: cell.posterImage.bounds.size))
            return cell
        }
        return cell
    }
    
    //  }
    
    //   return cell
    //  }
    
    
    
    
    
    func loadImagesForOnscreenRows(){
        if (arrayOfPosts.count > 0){
            let visiblePaths:NSArray = tableView.indexPathsForVisibleRows!
            for indexPath in visiblePaths {
                let post = arrayOfPosts[indexPath.row]
                if (indexPath.row % 2 == 0){
                    
                    let cell:TopCell = self.tableView.cellForRowAtIndexPath(indexPath as! NSIndexPath) as! TopCell
                    
                    cell.profileImage.sd_setImageWithURL(
                        NSURL(string: PFUser.currentUser()!.objectForKey("smallProfileImage") as! String),
                        placeholderImage: getImageWithColor(UIColor.lightGrayColor(), size: cell.profileImage.bounds.size),
                        options: SDWebImageOptions.RefreshCached, completed:{(
                            image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                            cell.profileImage.image = Toucan(image: image).maskWithEllipse().image
                    })
                    
                }
                else{
                    let cell: ContentCell = self.tableView.cellForRowAtIndexPath(indexPath as! NSIndexPath) as! ContentCell
                    cell.posterImage.sd_setImageWithURL(NSURL(string: "http://www.freemovieposters.net/posters/titanic_1997_6121_poster.jpg")!, placeholderImage: self.getImageWithColor(.grayColor(), size: cell.posterImage.bounds.size))
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate){
            loadImagesForOnscreenRows()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        loadImagesForOnscreenRows()
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetailedPost", sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = arrayOfPosts.count
        if (count == 0)
        {
            return 7;
        }
        return count;
        
    }

}








