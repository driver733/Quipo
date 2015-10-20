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
import FontBlaster
import TLYShyNavBar
import Parse
import SDWebImage
import Async



class ProfileVC: UIViewController {
  
  
  
  @IBOutlet weak var tableView: UITableView!
  var posterCollectionView: UICollectionView!
  
  var textArray: NSMutableArray! = NSMutableArray()
  var viewSelected = ""
  var loginActivityIndicator: UIActivityIndicatorView!
  var loginActivityIndicatorBackgroundView = UIView()
  
  
  var kPosterCollectionViewCellWidth = CGFloat()
  var kPosterCollectionViewCellHeight = CGFloat()
  
  var tableViewContentSizeWithPosterCollectionView = CGSize()
  
  func startLoginActivityIndicator() {
    loginActivityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 10, 10)) as UIActivityIndicatorView
    loginActivityIndicatorBackgroundView =  UIView(frame: self.view.frame)
    loginActivityIndicatorBackgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    loginActivityIndicatorBackgroundView.center = self.view.center
    //  loadingIndicatorBackgroundView.layer.cornerRadius = 10
    loginActivityIndicator.center = self.view.center
    loginActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    self.view.addSubview(loginActivityIndicatorBackgroundView)
    self.view.addSubview(loginActivityIndicator)
    loginActivityIndicator.startAnimating()
  }
  
  func stopLoginActivityIndicator() {
    if loginActivityIndicator != nil {
      loginActivityIndicator.stopAnimating()
      loginActivityIndicator.removeFromSuperview()
      loginActivityIndicatorBackgroundView.removeFromSuperview()
    }
  }
  
  
  func setupCollectionView() {
    
    kPosterCollectionViewCellWidth = (self.view.frame.width - 3) / 4
    kPosterCollectionViewCellHeight = kPosterCollectionViewCellWidth * 1.5
    
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
    layout.minimumInteritemSpacing = 1
    layout.minimumLineSpacing = 1
    
    layout.itemSize = CGSizeMake(kPosterCollectionViewCellWidth, kPosterCollectionViewCellHeight)
    
    
    let numberOfCellsInRow = 4
    let numberOfRows = ceil(((CGFloat(Post.sharedInstance.allUserPosts.count) / CGFloat(numberOfCellsInRow))))
    let posterCollectionViewHeight = kPosterCollectionViewCellHeight * CGFloat(numberOfRows) + 10
    
    
    self.posterCollectionView = UICollectionView(frame: CGRectMake(0, tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).maxY, self.view.frame.width, posterCollectionViewHeight), collectionViewLayout: layout)
    posterCollectionView.scrollEnabled = false
    posterCollectionView.dataSource = self
    posterCollectionView.delegate = self
    posterCollectionView.registerClass(PosterCollectionViewCell.self, forCellWithReuseIdentifier: "posterCell")
    posterCollectionView.backgroundColor = UIColor.clearColor()
    posterCollectionView.hidden = true
    self.view.addSubview(posterCollectionView)
    
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishLoadingStartupData:", name: "didFinishLoadingStartupData", object: nil)
    
    tableView.registerNib(UINib(nibName: "ProfileTopCell", bundle: nil), forCellReuseIdentifier: "ProfileTopCell")
    tableView.registerNib(UINib(nibName: "ProfileUserReviews", bundle: nil), forCellReuseIdentifier: "ProfileUserReviews")
    tableView.registerNib(UINib(nibName: "ProfileFollowerCell", bundle: nil), forCellReuseIdentifier: "ProfileFollowerCell")
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 44.0;
    
    // shyNavBarManager.scrollView = self.tableView
    
    let gesture = UITapGestureRecognizer(target: self, action: "cellPressed:")
    self.view.addGestureRecognizer(gesture)
    gesture.cancelsTouchesInView = false
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: "settings:")
    
    viewSelected = "following"
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
  //  if !UserSingelton.sharedInstance.hasLoadedStartupData {
 //     startLoginActivityIndicator()
 //   }
    
    
  }
  
  
  
  func didFinishLoadingStartupData(notif: NSNotification) {
    stopLoginActivityIndicator()
    tableView.reloadData()
    posterCollectionView.reloadData()
  }
  
  
  override func viewWillAppear(animated: Bool) {
    viewSelected = "following"
    self.navigationController?.navigationBar.barTintColor = UIColor.quipoColor()
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    self.title = "Profile"
    UserSingelton.sharedInstance.hasLoadedStartupData = false
    startLoginActivityIndicator()
    UserSingelton.sharedInstance.updateData().continueWithBlock { (task: BFTask!) -> AnyObject! in
      
      self.tableView.reloadData()
      if let posterCollectionView = self.posterCollectionView {
        posterCollectionView.reloadData()
        //   self.tableView.contentSize = self.tableViewContentSizeWithPosterCollectionView
      }
      self.stopLoginActivityIndicator()
      
      return nil
    }
    
    
  }
  
  
  
  override func viewDidAppear(animated: Bool) {
    if let posterView = posterCollectionView where tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) != nil {
      if !posterView.hidden {
        //  tableView.contentSize = tableViewContentSizeWithPosterCollectionView
      }
    }
    
    
  }
  func settings(sender: UIBarButtonItem) {
    performSegueWithIdentifier("profileSettings", sender: nil)
  }
  
  
  
  
  func cellPressed(press: UITapGestureRecognizer) {
    
    if press.state == .Ended {
      let location = press.locationInView(tableView)
      let path = tableView.indexPathForRowAtPoint(location)
      if path?.row == 0  {
        let newCell: ProfileTopCell = tableView.cellForRowAtIndexPath(path!) as! ProfileTopCell
        
        var viewPoint = newCell.awaitedView.convertPoint(location, fromView: tableView)
        if newCell.awaitedView.pointInside(viewPoint, withEvent: nil) {
          
          viewSelected = "reviews"
          
          //       posterCollectionView.hidden = true
          tableView.reloadData()
          
        }
        
        viewPoint = newCell.favouriteView.convertPoint(location, fromView: tableView)
        if newCell.favouriteView.pointInside(viewPoint, withEvent: nil){
          
          viewSelected = ""
          //      posterCollectionView.hidden = true
          tableView.reloadData()
        }
        
        viewPoint = newCell.watchedView.convertPoint(location, fromView: tableView)
        if newCell.watchedView.pointInside(viewPoint, withEvent: nil){
          
        }
        
        viewPoint = newCell.followingView.convertPoint(location, fromView: tableView)
        if newCell.followingView.pointInside(viewPoint, withEvent: nil) {
          viewSelected = "following"
          posterCollectionView.hidden = true
          tableView.reloadData()
        }
        
        viewPoint = newCell.followersView.convertPoint(location, fromView: tableView)
        if newCell.followersView.pointInside(viewPoint, withEvent: nil) {
          viewSelected = "followers"
          Async.main {
            self.posterCollectionView.hidden = true
            self.tableView.reloadData()
          }
        }
        
        viewPoint = newCell.userReviewsView.convertPoint(location, fromView: tableView)
        if newCell.userReviewsView.pointInside(viewPoint, withEvent: nil) {
          viewSelected = "userReviews"
          tableView.reloadData()
          posterCollectionView.reloadData()
        //  tableView.contentSize = tableViewContentSizeWithPosterCollectionView
        }
        
        
      }
      
      
    }
    
    
  }
  
  
  
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  
  
  
  
}



extension ProfileVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if posterCollectionView != nil {
      if viewSelected != "userReviews" {
        posterCollectionView.hidden = true
      } else {
        posterCollectionView.hidden = false
      }
    }
    
    
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
      cell.userReviewsView.layer.cornerRadius = 8
      cell.userReviewsView.layer.masksToBounds = true
      
      
      cell.selectionStyle = .None
      
      if let profileImage = PFUser.currentUser()?["bigProfileImage"] as? String {
        cell.profileImageView.sd_setImageWithURL(NSURL(string: profileImage), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImageView.bounds.size), options: SDWebImageOptions.RefreshCached, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
          if let image = image where error == nil {
            cell.profileImageView.image = Toucan(image: image).maskWithEllipse().image
          }
        })
      }
      
      
      
      cell.userReviewsCount.text = String(Post.sharedInstance.allUserPosts.count)
      cell.followingCount.text = String(UserSingelton.sharedInstance.following.count)
      cell.followersCount.text = String(UserSingelton.sharedInstance.followers.count)
      
      
      return cell
    }
      
    else {
      
      
      switch viewSelected {
        
        
      case "following":
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
        
        let user = (UserSingelton.sharedInstance.following)[indexPath.row - 1]
        
        cell.userName.text = user.username
        cell.followButton.addTarget(self, action: "didTapFollowButton:", forControlEvents: UIControlEvents.TouchUpInside)
        if user.isFollowed {
          cell.followButton.setTitle("following", forState: .Normal)
          cell.followButton.setTitleColor(.greenColor(), forState: .Normal)
        }
        cell.profileImage.sd_setImageWithURL(
          NSURL(string: user.profileImageURL!),
          placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
          options: SDWebImageOptions.RefreshCached,
          completed:{
            (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
            if image != nil {
              cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
            }
          }
        )
        
        
        return cell
        
        
        
      case "followers":
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
        let user = (UserSingelton.sharedInstance.followers)[indexPath.row - 1]
        
        cell.userName.text = user.username
        cell.followButton.addTarget(self, action: "didTapFollowButton:", forControlEvents: UIControlEvents.TouchUpInside)
        if user.isFollowed == true {
          cell.followButton.setTitle("following", forState: .Normal)
          cell.followButton.setTitleColor(.greenColor(), forState: .Normal)
        }
        cell.profileImage.sd_setImageWithURL(
          NSURL(string: user.profileImageURL!),
          placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImage.bounds.size),
          options: SDWebImageOptions.RefreshCached,
          completed:{
            (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
            if image != nil {
              cell.profileImage.image = Toucan(image: image).resize(cell.profileImage.bounds.size, fitMode: .Clip).maskWithEllipse().image
            }
          }
        )
        
        
        return cell
        
        
        
        
        
      default:
        return UITableViewCell()
      }
      
    }
    
  }
  
  
}







extension ProfileVC: UITableViewDelegate {
  
  
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == 0 {
      if posterCollectionView == nil {
        setupCollectionView()
      }
    }
    
    
  }
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch viewSelected {
      
    case "userReviews":
      return 1
      
    case "following":
      return UserSingelton.sharedInstance.following.count + 1
      
    case "followers":
      return UserSingelton.sharedInstance.followers.count + 1
      
    default: break
    }
    
    
    return 1
  }
  
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  
}





extension ProfileVC: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return Post.sharedInstance.allUserPosts.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = posterCollectionView.dequeueReusableCellWithReuseIdentifier("posterCell", forIndexPath: indexPath) as! PosterCollectionViewCell
    
    if indexPath.row == 1 {
      cell.backgroundColor = UIColor.blackColor()
    }
    
    let imgView = UIImageView(frame: CGRectMake(0, 0, kPosterCollectionViewCellWidth, kPosterCollectionViewCellHeight))
    cell.addSubview(imgView)
    
    imgView.sd_setImageWithURL(NSURL(string: Post.sharedInstance.allUserPosts[indexPath.row].standardPosterImageURL!), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.frame.size))
    return cell
  }
  
}



extension ProfileVC: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let vc = DetailedPostVC()
    vc.passedPost = Post.sharedInstance.allUserPosts[indexPath.row]
    let posterImage = ((posterCollectionView.cellForItemAtIndexPath(indexPath) as! PosterCollectionViewCell).subviews[1] as! UIImageView).image!
    let resizedPosterImage = Toucan(image: posterImage).resize(CGSizeMake(50, 50), fitMode: Toucan.Resize.FitMode.Scale).image
    let colors = getPrimaryPosterImageColorAndtextColor(resizedPosterImage)
    vc.passedColor = colors[1]
    vc.textColor = colors[0]
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == Post.sharedInstance.allUserPosts.count - 1  {
      let topTableViewCellHeight = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).height
      tableViewContentSizeWithPosterCollectionView = CGSizeMake(self.view.frame.width, topTableViewCellHeight + posterCollectionView.frame.height)
      if !posterCollectionView.hidden {
        tableView.contentSize = tableViewContentSizeWithPosterCollectionView
      }
    }
    
  }
  
  
  
}





extension ProfileVC: UICollectionViewDelegateFlowLayout {
  
  
  
  
  
  
}














