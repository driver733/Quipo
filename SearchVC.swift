//
//  SearchVC.swift
//  Moviethete
//
//  Created by Mike on 8/15/15.
//  Copyright © 2015 BIBORAM. All rights reserved.
//

import UIKit
import SwiftyJSON
import ITunesSwift
import SDWebImage

class SearchVC: UIViewController {
    
  @IBOutlet var tableView: UITableView!
 
  @IBOutlet weak var tempView: UIView!
    
  var searchController = UISearchController()
  var searchResults: [searchResult] = [searchResult](){
      didSet {self.tableView.reloadData()}
  }
  var tempStr = ""
  var lastContentOffset = CGFloat()
  var isTabBarHidden = Bool()
  
    override func viewDidLoad() {
      super.viewDidLoad()
      NSBundle.mainBundle().loadNibNamed("Search", owner: self, options: nil)
      tableView.registerNib(UINib(nibName: "SearchResultCell", bundle: nil), forCellReuseIdentifier: "SearchResultCell")
      tableView.delegate = self
      tableView.dataSource = self
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 44.0
      
      
      let notificationCenter = NSNotificationCenter.defaultCenter()
      notificationCenter.addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
      
        
        // Configure countrySearchController
        searchController = ({
          let controller = UISearchController(searchResultsController: nil)
          controller.searchResultsUpdater = self
          controller.delegate = self
          controller.hidesNavigationBarDuringPresentation = false
          controller.dimsBackgroundDuringPresentation = false
          controller.searchBar.searchBarStyle = .Minimal
          controller.searchBar.sizeToFit()
          controller.searchBar.placeholder = "Minimum 2 characters"
          controller.searchBar.tintColor = UIColor.blueColor()
          return controller
        })()

      
      tempView.addSubview(searchController.searchBar)
      
      
      
      
  
      
      
    }
  

  
  func keyboardDidHide(notif: NSNotification) {
    tempStr = searchController.searchBar.text!
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    
    func getMovieInfoByTitleAtCountry(movieTitle: String, country: String, completionHandler: ((responseJSON : JSON) -> Void)) {
        ITunesApi.find(Entity.Movie).by(movieTitle).at(country).request({ (responseString: String?, error: NSError?) -> Void in
            if error == nil, let responseString = responseString,
                let dataFromString = responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    return completionHandler(responseJSON: JSON(data: dataFromString))
            }
        })
    }
    
    
    func getMovieInfoByITunesID(iTunesID: Int, completionHandler: ((responseJSON : JSON) -> Void)) {
        ITunesApi.lookup(iTunesID).request({ (responseString: String?, error: NSError?) -> Void in
          if error == nil, let responseString = responseString, let dataFromString = responseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    return completionHandler(responseJSON: JSON(data: dataFromString))
            }
        })
    }
    
    
  func getReformattedReleaseDate(rawReleaseDate: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm::ssZ"
    let date = dateFormatter.dateFromString(rawReleaseDate)
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Day, .Month, .Year], fromDate: date!)
    return ("\(comp.day) \(dateFormatter.monthSymbols[comp.month-1]),\(comp.year)")
  }
  
  
  
  func getSmallPosterImageURLWithSize(defaultPosterImageURL: String) -> String {
    var str = defaultPosterImageURL
    str.replaceRange(Range<String.Index>(start: advance(str.endIndex, -14), end: advance(str.endIndex, -4)), with: "200x200-75")
    return str
  }
  
  /*
  - (void)setTabBarHidden:(BOOL)tabBarHidden animated:(BOOL)animated
  {
  if (tabBarHidden == _isTabBarHidden)
  return;
  
  CGFloat offset = tabBarHidden ? self.tabBarController.tabBar.frame.size.height : -self.tabBarController.tabBar.frame.size.height;
  
  [UIView animateWithDuration:0.6
  delay:0
  usingSpringWithDamping:0.7
  initialSpringVelocity:0.5
  options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionLayoutSubviews
  animations:^{
  self.tabBarController.tabBar.center = CGPointMake(self.tabBarController.tabBar.center.x,
  self.tabBarController.tabBar.center.y + offset);
  }
  completion:nil];
  
  _isTabBarHidden = tabBarHidden;
  }
  */
  
  
  func setTabBarHidden(tabBarHidden: Bool, animated: Bool) {
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

  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - UITableViewDataSource
extension SearchVC: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchController.active) {
         //   return searchArray.count
        } else {
     //       return searchResults.count
        }
      return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SearchResultCell") as! SearchResultCell
      
          let foundMovie = searchResults[indexPath.row]
          cell.movieTitle.text = foundMovie.movieTitle
          cell.genre.text = foundMovie.movieGenre
          cell.releaseDate.text = foundMovie.releaseDate
          cell.posterImage.sd_setImageWithURL(
            NSURL(string: foundMovie.smallPosterImageURL!),
            placeholderImage: getImageWithColor(UIColor.lightGrayColor(),
            size: cell.posterImage.bounds.size)
          )
            return cell
        }
  
}



extension SearchVC: UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
  
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      let cell = cell as! SearchResultCell
      cell.separatorInset.left = cell.posterImage.frame.origin.x + 10
  }
  

  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if lastContentOffset < scrollView.contentOffset.y {
      setTabBarHidden(true, animated: true)
    } else {
      setTabBarHidden(false, animated: true)
    }
    lastContentOffset = scrollView.contentOffset.y
  }
  
  
}





// MARK: - UISearchControllerDelegate
extension SearchVC: UISearchControllerDelegate {
  
  func didPresentSearchController(searchController: UISearchController) {
   // searchController.searchBar.showsCancelButton = false
   // searchController.searchBar.setShowsCancelButton(false, animated: false)
  }
  
  
}

// MARK: - UISearchResultsUpdating
extension SearchVC: UISearchResultsUpdating {
  
    func updateSearchResultsForSearchController(searchController: UISearchController){
     
      if searchController.searchBar.text != tempStr {
        searchResults.removeAll(keepCapacity: false)
        let userSearchInput = searchController.searchBar.text!
        if userSearchInput.characters.count > 1 {
            getMovieInfoByTitleAtCountry(userSearchInput, country: "US", completionHandler: { (responseJSON: JSON) -> Void in
                for (_, subJSON) in responseJSON["results"] {
                  let foundMovie = searchResult(
                    theMovieTitle: subJSON["trackName"].string!,
                    theMovieGenre: subJSON["primaryGenreName"].string!,
                    theMovieReleaseDate: self.getReformattedReleaseDate(subJSON["releaseDate"].string!),
                    theSmallPosterImageURL: self.getSmallPosterImageURLWithSize(subJSON["artworkUrl100"].string!),
                    theBigPosterImageURL: subJSON["artworkUrl100"].string!)
                  self.searchResults.append(foundMovie)
                }
            })
        }
      }
      
        
       // let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
       // let array = (self.countryArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
       // self.searchArray = array as! [String]
    }
}















