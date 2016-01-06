//
//  ProfileVC.swift
//  Reviews
//
//  Created by Mikhail Yakushin on 29/06/15.
//  Copyright (c) 2015 Mikhail Yakushin. All rights reserved.
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
import Parse
import SDWebImage
import Async

 enum viewType {
  case userReviews
  case watched
  case favorite
  case watchlist
  case followers
  case following
}

 class ProfileVC: UIViewController {
  
  var tableView = UITableView()
  
  var shouldUpdateLinkedAccounts = false
  
  var posterCollectionView : UICollectionView!
  var refreshControl = UIRefreshControl()
  
  var isDataLoaded = false
  
  var textArray: NSMutableArray! = NSMutableArray()
  var selectedView = viewType.userReviews
  var loginActivityIndicator: UIActivityIndicatorView!
  var loginActivityIndicatorBackgroundView = UIView()
  
  var kPosterCollectionViewCellWidth = CGFloat()
  var kPosterCollectionViewCellHeight = CGFloat()
  
  var user: User!
  
  init(theUser: User) {
    user = theUser
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func awakeFromNib() {
    user = CurrentUser.sharedCurrentUser()
  }
  
  func setupPosterCollectionView() {
    kPosterCollectionViewCellWidth = (self.view.frame.width - 3) / 4
    kPosterCollectionViewCellHeight = kPosterCollectionViewCellWidth * 1.5
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
    layout.minimumInteritemSpacing = 1
    layout.minimumLineSpacing = 1
    layout.itemSize = CGSizeMake(kPosterCollectionViewCellWidth, kPosterCollectionViewCellHeight)
    var posterCollectionViewHeight: CGFloat = 0
    let numberOfCellsInRow = 4
    let numberOfRows = ceil(((CGFloat(user.userPosts.count) / CGFloat(numberOfCellsInRow))))
    posterCollectionViewHeight = kPosterCollectionViewCellHeight * CGFloat(numberOfRows)
    posterCollectionView = UICollectionView(
      frame: CGRectMake(0, tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).maxY, self.view.frame.width, posterCollectionViewHeight),
      collectionViewLayout: layout)
    posterCollectionView.scrollEnabled = false
    posterCollectionView.delegate = self
    posterCollectionView.dataSource = self
    posterCollectionView.registerClass(PosterCollectionViewCell.self, forCellWithReuseIdentifier: "posterCell")
    posterCollectionView.backgroundColor = UIColor.clearColor()
    self.view.addSubview(posterCollectionView)
  }
  
  func updatePosterCollectionViewFrame() {
    let numberOfCellsInRow = 4
    let numberOfRows = ceil(((CGFloat(user.userPosts.count) / CGFloat(numberOfCellsInRow))))
    let posterCollectionViewHeight = kPosterCollectionViewCellHeight * CGFloat(numberOfRows)
    posterCollectionView.frame = CGRectMake(0, tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).maxY, self.view.frame.width, posterCollectionViewHeight)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView = UITableView()
    self.view = tableView
    tableView.registerNib(UINib(nibName: "ProfileTopCell", bundle: nil), forCellReuseIdentifier: "ProfileTopCell")
    tableView.registerNib(UINib(nibName: "ProfileUserReviews", bundle: nil), forCellReuseIdentifier: "ProfileUserReviews")
    tableView.registerNib(UINib(nibName: "ProfileFollowerCell", bundle: nil), forCellReuseIdentifier: "ProfileFollowerCell")
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 44.0;
    
//    if let topItem = self.navigationController?.navigationBar.topItem {
//      topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
//    }
    
    let gesture = UITapGestureRecognizer(target: self, action: "cellPressed:")
    self.view.addGestureRecognizer(gesture)
    gesture.cancelsTouchesInView = false
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: "settings:")
    
    tableView.tableFooterView = UIView(frame: CGRectZero)

    refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
    
  //  refreshControl.beginRefreshing()
    
    refresh(nil)
    
    if user.pfUser == CurrentUser.sharedCurrentUser().pfUser {
      self.title = self.user.username
    }
    
  }
  
  func refresh(sender: AnyObject?) {
    if shouldUpdateLinkedAccounts {
      CurrentUser.sharedCurrentUser().updateUserSubscriptions(
        CurrentUser.sharedCurrentUser().followedUsers,
        unfollowedUsersObjectIDs: CurrentUser.sharedCurrentUser().unfollowedUsers
        )
        .continueWithBlock({ (task: BFTask!) -> AnyObject! in
          self.shouldUpdateLinkedAccounts = false
          self.refresh(nil)
          return nil
        })
    } else {
      user.updateAllProfileData().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
        Async.main {
          self.title = self.user.username
          self.refreshControl.endRefreshing()
          self.tableView.reloadData()
          self.updatePosterCollectionViewFrame()
          self.posterCollectionView.reloadData()
        }
        return nil
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    shouldUpdateLinkedAccounts = false
    self.navigationController?.navigationBar.barTintColor = UIColor.quipoColor()
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
  }
  
  override func viewWillDisappear(animated: Bool) {
    if shouldUpdateLinkedAccounts {
      CurrentUser.sharedCurrentUser().updateUserSubscriptions(
                                  CurrentUser.sharedCurrentUser().followedUsers,
        unfollowedUsersObjectIDs: CurrentUser.sharedCurrentUser().unfollowedUsers
      )
      .continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
        self.shouldUpdateLinkedAccounts = false
        return nil
      })
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
           posterCollectionView.hidden = false
        }
        
        viewPoint = newCell.favouriteView.convertPoint(location, fromView: tableView)
        if newCell.favouriteView.pointInside(viewPoint, withEvent: nil) {
          selectedView = viewType.favorite
          posterCollectionView.hidden = false
        }
        
        viewPoint = newCell.watchedView.convertPoint(location, fromView: tableView)
        if newCell.watchedView.pointInside(viewPoint, withEvent: nil) {
          selectedView = viewType.watched
           posterCollectionView.hidden = false
        }
        
        viewPoint = newCell.userReviewsView.convertPoint(location, fromView: tableView)
        if newCell.userReviewsView.pointInside(viewPoint, withEvent: nil) {
          selectedView = viewType.userReviews
          posterCollectionView.hidden = false
        }
        
        viewPoint = newCell.followingView.convertPoint(location, fromView: tableView)
        if newCell.followingView.pointInside(viewPoint, withEvent: nil) {
          selectedView = viewType.following
          posterCollectionView.hidden = true
        }
        
        viewPoint = newCell.followersView.convertPoint(location, fromView: tableView)
        if newCell.followersView.pointInside(viewPoint, withEvent: nil) {
          selectedView = viewType.followers
          posterCollectionView.hidden = true
        }
        
        Async.main {
          let offset = self.tableView.contentOffset
          self.tableView.reloadData()
          self.tableView.layoutIfNeeded()
          self.tableView.setContentOffset(offset, animated: false)
          self.posterCollectionView.reloadData()
        }
        
      }
      
      
    }
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func indexPathForButton(sender: UIButton) -> NSIndexPath {
    let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
    let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)
    if let indexPath = indexPath {
      return indexPath
    }
    return NSIndexPath()
  }
  
  func processSubscriptionForUser(user: PFUser, cell: ProfileFollowerCell) {
    if cell.followButton.titleLabel?.text == "+ follow" {
      CurrentUser.sharedCurrentUser().followedUsers.append(user.objectId!)
      cell.followButton.setTitle("following", forState: .Normal)
      cell.followButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
    } else {
      CurrentUser.sharedCurrentUser().unfollowedUsers.append(user.objectId!)
      cell.followButton.setTitle("+ follow", forState: .Normal)
      cell.followButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
    }
    shouldUpdateLinkedAccounts = true
  }
  
  func cellIndexPathRow(row: Int) -> Int {
    return row - 1
  }
  
  func didTapFollowersFollowButton(sender: UIButton) {
    let indexPath = indexPathForButton(sender)
    let user = CurrentUser.sharedCurrentUser().followers[cellIndexPathRow(indexPath.row)].pfUser!
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! ProfileFollowerCell
    processSubscriptionForUser(user, cell: cell)
  }
  
  func didTapFollowingUsersFollowButton (sender: UIButton) {
    let indexPath = indexPathForButton(sender)
    let user = CurrentUser.sharedCurrentUser().following[cellIndexPathRow(indexPath.row)].pfUser!
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! ProfileFollowerCell
    processSubscriptionForUser(user, cell: cell)
  }

  
}


// MARK: - UITableViewDataSource

extension ProfileVC: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
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
        cell.profileImageView.sd_setImageWithURL(NSURL(string: profileImage), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.profileImageView.bounds.size), options: SDWebImageOptions.RefreshCached,
          completed: {
          (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
          if let image = image where error == nil {
            cell.profileImageView.image = Toucan(image: image).maskWithEllipse().image
          }
        })
      }
      
     // if isDataLoaded {
      
        cell.userReviewsCount.text = String(user.userPosts.count)
        cell.followersCount.text = String(user.followers.count)
        cell.followingCount.text = String(user.following.count)
        cell.watchedCount.text = String(user.watchedPosts.count)
        cell.favouriteCount.text = String(user.favoritePosts.count)
       // TODO:  implement awaitedCount
        cell.awaitedCount.text = "0"
      
      //  cell.awaitedCount.text = String(user.)
//      } else {
//        cell.userReviewsCount.text = ""
//        cell.followersCount.text = ""
//        cell.followingCount.text = ""
//        cell.watchedCount.text = ""
//        cell.favouriteCount.text = ""
//        cell.awaitedCount.text = ""
//      }
      
      return cell
    }
      
    else {
      
      
      switch selectedView {
        
        
      case .following:
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
        
        let theUser = (user.following)[indexPath.row - 1]
        cell.userName.text = theUser.username
     //   cell.followButton.addTarget(self, action: "didTapFollowingUsersFollowButton:", forControlEvents: UIControlEvents.TouchUpInside)
        if theUser.isFollowed {
          cell.followButton.setTitle("following", forState: .Normal)
          cell.followButton.setTitleColor(.greenColor(), forState: .Normal)
        }
        cell.profileImage.sd_setImageWithURL(
          NSURL(string: theUser.profileImageURL!),
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
        
      case .followers:
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFollowerCell", forIndexPath: indexPath) as! ProfileFollowerCell
       
        let theUser = (user.followers)[indexPath.row - 1]
        
        cell.userName.text = theUser.username
    //    cell.followButton.addTarget(self, action: "didTapFollowersFollowButton:", forControlEvents: UIControlEvents.TouchUpInside)
        if theUser.isFollowed {
          cell.followButton.setTitle("following", forState: .Normal)
          cell.followButton.setTitleColor(.greenColor(), forState: .Normal)
        }
        cell.profileImage.sd_setImageWithURL(
          NSURL(string: theUser.profileImageURL!),
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
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedView {
    case .following:
      return user.following.count + 1
    case .followers:
      return user.followers.count + 1
    default:
      return 1
    }
  }

  
}





// MARK: - UITableViewDelegate

extension ProfileVC: UITableViewDelegate {
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == 0 && posterCollectionView == nil {
        setupPosterCollectionView()
    }
    if indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
      cell.separatorInset = UIEdgeInsetsZero
    }
  }
  
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row != 0 {
      switch selectedView {
      case .followers:
        let selectedUser = user.followers[indexPath.row - 1]
        let vc = ProfileVC(theUser: selectedUser)
        self.navigationController?.pushViewController(vc, animated: true)
      case .following:
        let selectedUser = user.following[indexPath.row - 1]
        let vc = ProfileVC(theUser: selectedUser)
        self.navigationController?.pushViewController(vc, animated: true)
      default:
        break
      }
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  
  
}



// MARK: - UICollectionViewDataSource

extension ProfileVC: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch selectedView {
      
    case .userReviews:
      return user.userPosts.count
      
    default:
      return 0
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = posterCollectionView.dequeueReusableCellWithReuseIdentifier("posterCell", forIndexPath: indexPath) as! PosterCollectionViewCell
    let imgView = UIImageView(frame: CGRectMake(0, 0, kPosterCollectionViewCellWidth, kPosterCollectionViewCellHeight))
    cell.addSubview(imgView)
    switch selectedView {
    case .userReviews:
      imgView.sd_setImageWithURL(NSURL(string: user.userPosts[indexPath.row].standardPosterImageURL!), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.frame.size))
    case .watched:
      imgView.sd_setImageWithURL(NSURL(string: user.watchedPosts[indexPath.row].standardPosterImageURL!), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.frame.size))
    case .favorite:
      imgView.sd_setImageWithURL(NSURL(string: user.favoritePosts[indexPath.row].standardPosterImageURL!), placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.frame.size))
    default:
      break
    }
    
    return cell
  }
  
}


// MARK: - UICollectionViewDelegate
extension ProfileVC: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let posterImage = (posterCollectionView.cellForItemAtIndexPath(indexPath)!.subviews[1] as! UIImageView).image!
    let colors = primaryPosterImageColorAndtextColor(posterImage)
    if selectedView == .userReviews {
      let post = user.userPosts[indexPath.row]
      let vc = DetailedPostVC(thePost: post, theNavBarBackgroundColor: colors.primaryColor, theNavBarTextColor: colors.inferredTextColor)
      self.navigationController?.pushViewController(vc, animated: true)
    } else if selectedView == .watched {
      let post = user.watchedPosts[indexPath.row]
      let vc = DetailedPostVC(thePost: post, theNavBarBackgroundColor: colors.primaryColor, theNavBarTextColor: colors.inferredTextColor)
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == user.userPosts.count - 1 {
      let topTableViewCellHeight = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).height
      let tableViewContentSizeWithPosterCollectionView = CGSizeMake(self.view.frame.width, topTableViewCellHeight + posterCollectionView.frame.height)
        tableView.contentSize = tableViewContentSizeWithPosterCollectionView
    }
    
  }
  
  
  
}



extension ProfileVC: LoadingStateDelegate {
  
  func didStartNetworingActivity() {
    refreshControl.beginRefreshing()
  }
  
  func didEndNetworingActivity() {
    refreshControl.endRefreshing()
  }
  
}








