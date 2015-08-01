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


class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var arrayOfPosts: [Post] = [Post]()

    
    override func viewDidLoad() {
         super.viewDidLoad()
         tableView.registerNib(UINib(nibName: "topCell", bundle: nil), forCellReuseIdentifier: "topCell")
         tableView.registerNib(UINib(nibName: "contentCell", bundle: nil), forCellReuseIdentifier: "contentCell")
         tableView.delegate = self
         tableView.dataSource = self
         tableView.rowHeight = UITableViewAutomaticDimension;
         tableView.estimatedRowHeight = 44.0;
         setUpPost()
         shyNavBarManager.scrollView = self.tableView;
        
        
        
        
        
        
        
        
        
        
      
          
    }
    
    
    
    
    
  //  override func viewDidAppear(animated: Bool) {
  //      tableView.setContentOffset((CGPointMake(0, 23)), animated: false)
  //  }
    
    
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
    
    
    
  
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        _ = arrayOfPosts.count;
/*
        if (indexPath.row == 0)
        {
            let cell:topCell = tableView.dequeueReusableCellWithIdentifier("topCell", forIndexPath: indexPath) as! topCell
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
                    let cell = tableView.dequeueReusableCellWithIdentifier("topCell", forIndexPath: indexPath) as! topCell
                    cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0); 
                    let post = arrayOfPosts[indexPath.row]
                    cell.userName.text = post.userName
                    cell.timeSincePosted.text = post.timeSincePosted
                    // Only load cached images; defer new downloads until scrolling ends
                   // if (post.profileImage == nil)
                   // {
                        if (!tableView.dragging && !tableView.decelerating)
                        {
                         //   cell.profileImage.setImageWithUrl(NSURL(string: "http://da4nikam.ru/wp-content/uploads/2010/12/e5_1_b.jpg")!, placeHolderImage: nil)
                            cell.profileImage.sd_setImageWithURL(NSURL(string: "http://da4nikam.ru/wp-content/uploads/2010/12/e5_1_b.jpg")!, placeholderImage: getImageWithColor(.grayColor(), size: cell.profileImage.bounds.size))
                            return cell
                                           }
                    return cell
                }
                // Set up the cell representing the app
                let cell = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath) as! contentCell
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
                Async.background(){
                let cell:topCell = self.tableView.cellForRowAtIndexPath(indexPath as! NSIndexPath) as! topCell
                cell.profileImage.sd_setImageWithURL(NSURL(string: "http://da4nikam.ru/wp-content/uploads/2010/12/e5_1_b.jpg")!, placeholderImage: self.getImageWithColor(.grayColor(), size: cell.profileImage.bounds.size))
                }
            }
           else{
                   Async.background(){
            let cell: contentCell = self.tableView.cellForRowAtIndexPath(indexPath as! NSIndexPath) as! contentCell
                  cell.posterImage.sd_setImageWithURL(NSURL(string: "http://www.freemovieposters.net/posters/titanic_1997_6121_poster.jpg")!, placeholderImage: self.getImageWithColor(.grayColor(), size: cell.posterImage.bounds.size))
                    }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailedPost" {
            if let vc = segue.destinationViewController as? DetailedPostVC {
                    vc.num = tableView.indexPathForSelectedRow!.row
            }
        }
    }
    
}


