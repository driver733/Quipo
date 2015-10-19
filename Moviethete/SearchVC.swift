//
//  SearchVC.swift
//  Moviethete
//
//  Created by Mike on 8/15/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import UIKit
import ITunesSwift
import SwiftyJSON
import SDWebImage
import Alamofire
import Async
import Bolts


let DID_SELECT_SEARCH_RESULT_CELL_SEGUE_IDENTIFIER = "didSelectSearchResultCell"


class SearchVC: UITableViewController {
  
  
  var searchController = UISearchController()
  var searchResults: [Post] = [Post]() {
    didSet {self.tableView.reloadData()}
  }
  var tempStr = ""
  var lastContentOffset = CGFloat()
  var isTabBarHidden = false
  var isSearchBarHidden = false
  var searchTimer: NSTimer? = nil
  var timerDone = Bool()
  var shouldFixInset = false
  var color = UIColor()
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    
    // Set up search controller
    searchController = ({
      let controller = UISearchController(searchResultsController: nil)
      controller.searchResultsUpdater = self
      controller.delegate = self
      controller.hidesNavigationBarDuringPresentation = false
      controller.dimsBackgroundDuringPresentation = false
      controller.searchBar.searchBarStyle = .Minimal
      controller.searchBar.sizeToFit()
      controller.searchBar.placeholder = "At least two letters"
      return controller
    })()
    
    tableView.registerNib(UINib(nibName: "SearchResultCell", bundle: nil), forCellReuseIdentifier: "SearchResultCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    
    // Add search bar
    self.navigationController?.navigationBar.addSubview(searchController.searchBar)
   
    // Fix for black table view after tab bar switch
    self.definesPresentationContext = true
    
    self.navigationController?.definesPresentationContext = true
    
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    self.navigationItem.title = ""
    
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blueColor()]
    self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
    
    self.navigationController?.navigationBar.translucent = false
    
    self.tabBarController?.tabBar.translucent = false

    // remove UINavigationBar`s bottom border
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
  }

  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if
      segue.identifier == DID_SELECT_SEARCH_RESULT_CELL_SEGUE_IDENTIFIER,
      let vc = segue.destinationViewController as? DetailedPostVC {
        let post = searchResults[(self.tableView.indexPathForSelectedRow?.row)!]
        self.searchController.searchBar.resignFirstResponder()
        vc.navigationItem.title = post.movieTitle!
        vc.passedPost = post
        let colors = getPrimaryPosterImageColorAndtextColor((tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as! SearchResultCell).posterImage.image!)
        color = colors[1]
        vc.passedColor = color
        vc.textColor = colors[0]
    }
  }
  

  override func viewWillAppear(animated: Bool) {
    self.transitionCoordinator()?.animateAlongsideTransition({
      (context: UIViewControllerTransitionCoordinatorContext) -> Void in
      if self.tableView.indexPathForSelectedRow != nil {
        self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: false)
      }
      self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
      self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
      // remove UINavigationBar`s bottom border
      self.navigationController?.navigationBar.shadowImage = UIImage()
      self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
      self.searchController.searchBar.hidden = false
      }, completion: {
        (completionContext: UIViewControllerTransitionCoordinatorContext) -> Void in
        if completionContext.initiallyInteractive() {
          if completionContext.completionVelocity() == -1.0 && completionContext.percentComplete() < 0.5 {
            self.searchController.searchBar.hidden = true
            self.navigationController?.navigationBar.barTintColor = self.color
          } else if completionContext.completionVelocity() < 0 {
            self.searchController.searchBar.hidden = true
            self.navigationController?.navigationBar.barTintColor = self.color
          } else {
            self.searchController.searchBar.hidden = false
            // remove UINavigationBar`s bottom border
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
            self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        }
        } else {
          // remove UINavigationBar`s bottom border
          self.navigationController?.navigationBar.shadowImage = UIImage()
          self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
          self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
        }
    })
  }

  
  
  func keyboardDidHide(notif: NSNotification) {
    tempStr = searchController.searchBar.text!
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
              NSURL(string: foundMovie.standardPosterImageURL!),
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
    cell.movieTitle.text = foundMovie.movieTitle
    cell.localizedMovieTitle.text = foundMovie.localizedMovieTitle
    cell.genre.text = foundMovie.movieGenre
    cell.releaseDate.text = foundMovie.movieReleaseDate
    
    if (tableView.dragging || tableView.decelerating) {
    
      SDWebImageManager.sharedManager().cachedImageExistsForURL(NSURL(string: foundMovie.standardPosterImageURL!), completion: {
        (exists: Bool) -> Void in
        if exists {
          cell.posterImage.sd_setImageWithURL(
            NSURL(string: foundMovie.standardPosterImageURL!),
            placeholderImage: self.getImageWithColor(UIColor.placeholderColor(), size: cell.posterImage.bounds.size),
            options: SDWebImageOptions.AvoidAutoSetImage,
            completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
              if error == nil && image != nil {
                cell.posterImage.image = Toucan(image: image).resize(cell.posterImage.bounds.size, fitMode: .Scale).image
              }
            }
          )
        }
      })
    
    return cell
    
  } else {
    cell.posterImage.sd_setImageWithURL(
    NSURL(string: foundMovie.standardPosterImageURL!),
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
    performSegueWithIdentifier(DID_SELECT_SEARCH_RESULT_CELL_SEGUE_IDENTIFIER, sender: nil)
    // tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  
   override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let cell = cell as! SearchResultCell
    cell.separatorInset.left = cell.posterImage.frame.origin.x + 10
  }
  
  
// MARK: - UIScrollViewDelegate
  
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





// MARK: - UISearchControllerDelegate
extension SearchVC: UISearchControllerDelegate {
  
  func didPresentSearchController(searchController: UISearchController) {
    
  }
  
}

// MARK: - UISearchResultsUpdating
extension SearchVC: UISearchResultsUpdating {
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    if searchController.searchBar.text?.characters.count == 0 {
      searchResults.removeAll(keepCapacity: false)
    } else {
      searchTimer?.invalidate()
      searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: "timerDone:", userInfo: nil, repeats: false)
    }
  }
  
  func timerDone(timer: NSTimer) {
    if searchController.searchBar.text != tempStr {
      searchResults.removeAll(keepCapacity: false)
      let userSearchInput = searchController.searchBar.text!
      if userSearchInput.characters.count > 1 {
        
        ITunes.sharedInstance.getMovieInfoByTitleAtCountry(userSearchInput, country: "US").continueWithBlock({
          (task: BFTask!) -> AnyObject! in
          let result = task.result as! NSData
          let responseJSON = JSON(data: result)
          
          for (_, subJSON) in responseJSON {
            let foundMovie = Post(
              theTrackID: subJSON["trackId"].numberValue.integerValue,
              theMovieTitle: subJSON["trackName"].stringValue,
              theLocalizedMovieTitle: subJSON["trackName"].stringValue,
              theMovieGenre: subJSON["primaryGenreName"].stringValue,
              theMovieReleaseDate: Post.sharedInstance.getReformattedReleaseDate(subJSON["releaseDate"].stringValue),
              theStandardPosterImageURL: ITunes.sharedInstance.getStandardPosterImageURL(subJSON["artworkUrl100"].stringValue)
            )
            self.searchResults.append(foundMovie)
          }
          return nil
        })
        
      }
    }

  }
  
  
  
}










