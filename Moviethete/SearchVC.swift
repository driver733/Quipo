//
//  SearchVC.swift
//  Quipo
//
//  Created by Mikhail Yakushin on 8/15/15.
//  Copyright © 2015 Mikhail Yakushin. All rights reserved.
//

import UIKit
//import ITunesSwift
import SwiftyJSON
import SDWebImage
import Alamofire
import Async
import Bolts
import QuartzCore


let DID_SELECT_SEARCH_RESULT_CELL_SEGUE_IDENTIFIER = "didSelectSearchResultCell"

let kPosterMatcherDistanceToLeftMargin: CGFloat = 10
let kSearchBarDistanceToRightMargin: CGFloat = 10
let kPosterMatcherButtonDistanceToSeachBar: CGFloat = 10
let kPosterMatcherButtonHeight: CGFloat = 30 // equals to SearchBar textfield height
let kPosterMatcherButtonWidth: CGFloat = 20  // follows original image ration of 1/2


class SearchVC: UITableViewController, LoadingStateDelegate {
  
  var viewToCoverCancelButtonRemovalAnimation: UIView!
  var searchBarBaseView: UIView!
  
  var searchController: UISearchController!
  var searchResults: [Post] = [Post]() {
    didSet {
      self.tableView.reloadData()
      if searchResults.isEmpty && searchController.searchBar.isFirstResponder() && searchController.searchBar.text?.characters.count > 0 {
        tableView.tableFooterView = UITableViewCell.noSearchResultsCell(self.view)
      } else {
        tableView.tableFooterView = UIView(frame: CGRectZero)
      }
    }
  }
  var tempStr = ""
  var lastContentOffset = CGFloat()
  var isTabBarHidden = false
  var isSearchBarHidden = false
  var searchTimer: NSTimer?
  var timerDone = Bool()
  var shouldFixInset = false
  var color = UIColor()
  var matchPoster: UIButton!
  
  
  func setUpNavBar() {
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    self.navigationItem.title = ""
    self.navigationController?.definesPresentationContext = true
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blueColor()]
    self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
    self.navigationController?.navigationBar.translucent = false
    self.navigationController?.navigationBar.barTintColor = UIColor.searchBarSuperviewBackgroundColor()
  }
  
  func setUpSearchBar() {
    searchController = ({
      let controller = UISearchController(searchResultsController: nil)
      controller.searchResultsUpdater = self
      controller.searchBar.delegate = self
      controller.hidesNavigationBarDuringPresentation = false
      controller.dimsBackgroundDuringPresentation = false
      controller.searchBar.searchBarStyle = .Minimal
      controller.searchBar.placeholder = "At least two letters..."
      return controller
    })()

    let searchBarX = kPosterMatcherDistanceToLeftMargin + kPosterMatcherButtonWidth + kPosterMatcherButtonDistanceToSeachBar
    let searchBarWidth = (self.navigationController?.navigationBar.frame.width)!-searchBarX-kSearchBarDistanceToRightMargin
    searchBarBaseView = UIView(frame: CGRectMake(searchBarX, 0, searchBarWidth, (self.navigationController?.navigationBar.frame.height)!))
    
    matchPoster = UIButton(type: UIButtonType.Custom)
    matchPoster.addTarget(self, action: Selector("didTapMatchPosterButton:"), forControlEvents: .TouchUpInside)
    matchPoster.setImage(UIImage(named: "posterMatcher"), forState: .Normal)
    matchPoster.frame = CGRectMake(kPosterMatcherDistanceToLeftMargin, 0, kPosterMatcherButtonWidth, kPosterMatcherButtonHeight)
    matchPoster.center.y = searchBarBaseView.center.y
    matchPoster.backgroundColor = UIColor.searchBarSuperviewBackgroundColor()
    
    searchBarBaseView.addSubview(searchController.searchBar)
    
    self.navigationController?.navigationBar.addSubview(searchBarBaseView)
    self.navigationController?.navigationBar.addSubview(matchPoster)
    
    searchController.searchBar.sizeToFit()
    
    let navBarFrame = self.navigationController!.navigationBar.frame
    viewToCoverCancelButtonRemovalAnimation = UIView(frame: CGRectMake(navBarFrame.maxX - 15, 5, 50, searchController.searchBar.frame.height - 10))
    viewToCoverCancelButtonRemovalAnimation.backgroundColor = self.navigationController?.navigationBar.barTintColor
    self.navigationController?.navigationBar.addSubview(viewToCoverCancelButtonRemovalAnimation)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpNavBar()
    setUpSearchBar()
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
    tableView.registerNib(UINib(nibName: "SearchResultCell", bundle: nil), forCellReuseIdentifier: "SearchResultCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
   
    self.definesPresentationContext = true  // Fix for black table view after tab bar switch
    self.tabBarController?.tabBar.translucent = false
    
    let gesture = UITapGestureRecognizer(target: self, action: "didTapSuperview:")
    self.view.addGestureRecognizer(gesture)
    gesture.cancelsTouchesInView = false
    
    // remove UINavigationBar`s bottom border
    //    self.navigationController?.navigationBar.shadowImage = UIImage()
    //    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
  }
  
  func didTapMatchPosterButton(sender: UIButton) {
    let vc = PosterMatcherVC()
    vc.passedViewScreenshot = UIViewController.screenshot()
    vc.delegate = self
    self.presentViewController(vc, animated: true, completion: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if
      segue.identifier == DID_SELECT_SEARCH_RESULT_CELL_SEGUE_IDENTIFIER,
      let _ = segue.destinationViewController as? DetailedPostVC {
        let post = searchResults[(self.tableView.indexPathForSelectedRow?.row)!]
        self.searchController.searchBar.resignFirstResponder()
        let colors = primaryPosterImageColorAndtextColor((tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as! SearchResultCell).posterImage.image!)
        let vc = DetailedPostVC(thePost: post, theNavBarBackgroundColor: colors.primaryColor, theNavBarTextColor: colors.inferredTextColor)
        vc.navigationItem.title = post.movieTitle!
    }
  }
  
  override func viewDidLayoutSubviews() {
    if searchController.searchBar.isFirstResponder() {
      NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "hideCancelButton", userInfo: nil, repeats: false)
    }
  }
  
  func didTapSuperview(press: UITapGestureRecognizer) {
    if searchResults.isEmpty {
      self.searchController.searchBar.endEditing(true)
    }
  }
  
  func hideCancelButton() {
    let cancelButton = searchController.searchBar.subviews[0].subviews[2]
    cancelButton.hidden = true
    resizeSearchBarSuperview()
    searchController.searchBar.sizeToFit()
  }
  
  override func viewWillAppear(animated: Bool) {
    searchBarBaseView.hidden = false
    matchPoster.hidden = false
    
    
    self.transitionCoordinator()?.animateAlongsideTransition({
      (context: UIViewControllerTransitionCoordinatorContext) -> Void in
      if self.tableView.indexPathForSelectedRow != nil {
        self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: false)
      }
      self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
      self.navigationController?.navigationBar.barTintColor = UIColor.searchBarSuperviewBackgroundColor()
      // remove UINavigationBar`s bottom border
//      self.navigationController?.navigationBar.shadowImage = UIImage()
//      self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
      self.searchController.searchBar.hidden = false
      }, completion: {
        (completionContext: UIViewControllerTransitionCoordinatorContext) -> Void in
        self.viewToCoverCancelButtonRemovalAnimation.hidden = false
        if completionContext.initiallyInteractive() {
          if (completionContext.completionVelocity() == -1.0 && completionContext.percentComplete() < 0.5) ||
            completionContext.completionVelocity() < 0 {
            self.searchController.searchBar.hidden = true
            self.navigationController?.navigationBar.barTintColor = self.color
          }  else {
            self.searchController.searchBar.hidden = false
            // remove UINavigationBar`s bottom border
//            self.navigationController?.navigationBar.shadowImage = UIImage()
//            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//            self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
//            self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
          }
        } else {
          self.searchController.searchBar.hidden = false
          // remove UINavigationBar`s bottom border
//          self.navigationController?.navigationBar.shadowImage = UIImage()
//          self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//          self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
        }
    })
  }
  
  override func viewWillDisappear(animated: Bool) {
    matchPoster.hidden = true
    viewToCoverCancelButtonRemovalAnimation.hidden = true
    searchBarBaseView.hidden = true
  }
  
  func keyboardDidHide(notif: NSNotification) {
    tempStr = searchController.searchBar.text!
  }
  
  func loadingIndicatorState(show: Bool) {
    if show {
      tableView.tableFooterView = UITableViewCell.loadingIndicatorCell(self.view)
    } else {
      tableView.tableFooterView = UIView(frame: CGRectZero)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func setTabBarHidden(tabBarHidden: Bool) {
    if tabBarHidden == isTabBarHidden {
      return
    }
    let offset = tabBarHidden ? self.tabBarController!.tabBar.frame.size.height : -self.tabBarController!.tabBar.frame.size.height
    
    UIView.animateWithDuration(0.45,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0.5,
      options: UIViewAnimationOptions.CurveEaseInOut,
      animations: { () -> Void in
        self.tabBarController!.tabBar.center = CGPointMake(self.tabBarController!.tabBar.center.x, self.tabBarController!.tabBar.center.y + offset)
      },
      completion: nil)
    
    isTabBarHidden = tabBarHidden
  }
  
  
  
  func setSearchBarHidden(searchBarHidden: Bool) {
    if searchBarHidden == isSearchBarHidden {
      return
    }
    let offset = searchBarHidden ? -searchController.searchBar.frame.size.height : searchController.searchBar.frame.size.height
    UIView.animateWithDuration(0.45,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0.5,
      options: UIViewAnimationOptions.CurveEaseInOut,
      animations: { () -> Void in
        self.searchController.searchBar.center = CGPointMake(self.searchController.searchBar.center.x, self.searchController.searchBar.center.y + offset)
      },
      completion: nil)
    
    isSearchBarHidden = searchBarHidden
  }
  
  
  
  func loadImagesForOnscreenRows(){
    
    if (searchResults.count > 0){
      let visiblePaths = tableView.indexPathsForVisibleRows!
      for indexPath in visiblePaths {
        let foundMovie = searchResults[indexPath.row]
        let cell: SearchResultCell = self.tableView.cellForRowAtIndexPath(indexPath) as! SearchResultCell
        if searchResults.count > indexPath.row {
          cell.posterImage.sd_setImageWithURL(
            NSURL(string: foundMovie.smallPosterImageURL!),
            placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.posterImage.bounds.size)
          )
        }
      }
    }
  }
  
  
  
  // MARK: - UITableViewDataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (self.searchController.active) {
      //   return searchArray.count
    } else {
      //       return searchResults.count
    }
    return searchResults.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCellWithIdentifier("SearchResultCell") as! SearchResultCell
    
    let foundMovie = searchResults[indexPath.row]
    cell.movieTitle.text = ""
  //  cell.localizedMovieTitle.text = foundMovie.localizedMovieTitle
    // TODO: localize movie title
    cell.localizedMovieTitle.text = foundMovie.movieTitle
    cell.genre.text = foundMovie.movieGenre
    cell.releaseDate.text = foundMovie.releaseDate
    
    if (tableView.dragging || tableView.decelerating) {
      
      SDWebImageManager.sharedManager().cachedImageExistsForURL(NSURL(string: foundMovie.smallPosterImageURL!), completion: {
        (exists: Bool) -> Void in
        if exists {
          cell.posterImage.sd_setImageWithURL(
            NSURL(string: foundMovie.smallPosterImageURL!),
            placeholderImage: self.getImageWithColor(UIColor.placeholderColor(), size: cell.posterImage.bounds.size),
            options: SDWebImageOptions.AvoidAutoSetImage,
            completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
              if error == nil && image != nil {
                cell.posterImage.image = Toucan(image: image).resize(cell.posterImage.bounds.size, fitMode: .Scale).image
              }
            }
          )
        } else {
           cell.posterImage.image = self.getImageWithColor(.placeholderColor(), size: cell.posterImage.bounds.size)
        }
      })
      
      return cell
      
    } else {
      cell.posterImage.sd_setImageWithURL(
        NSURL(string: foundMovie.smallPosterImageURL!),
        placeholderImage: getImageWithColor(UIColor.placeholderColor(), size: cell.posterImage.bounds.size),
        options: SDWebImageOptions.AvoidAutoSetImage,
        completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
          if error == nil {
            cell.posterImage.image = Toucan(image: image).resize(cell.posterImage.bounds.size, fitMode: .Scale).image
          }
        }
      )
    }
    
    return cell
  }
  
  
  // MARK: - UITableViewDelegate

  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let post = searchResults[(self.tableView.indexPathForSelectedRow?.row)!]
    self.searchController.searchBar.resignFirstResponder()
    let colors = primaryPosterImageColorAndtextColor((tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as! SearchResultCell).posterImage.image!)
    let vc = DetailedPostVC(thePost: post, theNavBarBackgroundColor: colors.primaryColor, theNavBarTextColor: colors.inferredTextColor)
    vc.navigationItem.title = post.movieTitle!
    self.navigationController?.pushViewController(vc, animated: true)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let cell = cell as! SearchResultCell
    cell.separatorInset.left = cell.posterImage.frame.origin.x + 10
  }
  
  
  // MARK: - UIScrollViewDelegate
  
  override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    searchController.searchBar.endEditing(true)
  }
  
  override func scrollViewDidScrollToTop(scrollView: UIScrollView) {
    setTabBarHidden(false)
    setSearchBarHidden(false)
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    if !searchResults.isEmpty {
      if scrollView.contentOffset.y <= 0 {
      } else if lastContentOffset < scrollView.contentOffset.y {
      } else {
      }
      lastContentOffset = scrollView.contentOffset.y
    }
  }

  override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if (!decelerate){
      loadImagesForOnscreenRows()
    }
  }
  
  override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    loadImagesForOnscreenRows()
  }
  
}


// MARK: - UISearchResultsUpdating
extension SearchVC: UISearchResultsUpdating {
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    if searchController.searchBar.text?.characters.count == 0 {
      searchResults.removeAll(keepCapacity: false)
    } else {
      searchTimer?.invalidate()
      searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "timerDone:", userInfo: nil, repeats: false)
    }
  }
  
  func timerDone(timer: NSTimer) {
    if searchController.searchBar.text != tempStr {
      searchResults.removeAll(keepCapacity: false)
      let userSearchInput = searchController.searchBar.text!
      if userSearchInput.characters.count > 0 {
        loadingIndicatorState(true)
        ITunes.sharedInstance.movieInfoByTitleAtCountry(userSearchInput, country: "US", completionHandler: { (theSearchResults: [Post]) -> Void in
          self.loadingIndicatorState(false)
          self.searchResults = theSearchResults
        })
      }
    }
  }
  
}


// MARK: - dd



extension SearchVC: UISearchBarDelegate {
  
  func resizeSearchBarSuperview() {
    let searchBarSuperview = self.navigationController?.navigationBar.subviews[1]
    searchBarSuperview!.frame = CGRectMake(40, 0, (self.navigationController?.navigationBar.frame.width)!-40-10+70, (self.navigationController?.navigationBar.frame.height)!)
  }
}








