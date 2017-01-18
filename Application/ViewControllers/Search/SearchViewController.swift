//
//  SearchViewController.swift
//  Swan Music
//
//  Created by Alok Singh on 01/07/16.
//  Copyright (c) 2016 Swan Music. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SearchViewController: UIViewController,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    
    //MARK: - variables and constants
    @IBOutlet var tableView : UITableView!
    @IBOutlet var searchBar : UISearchBar!
    
    var searchStatus : SearchStatus = SearchStatus.notSearched
    var searchResults = NSMutableArray()
    
    //MARK: - view controller life cycle methods
    
    override var prefersStatusBarHidden : Bool {
        if (self.navigationController != nil) {
            return (self.navigationController?.isNavigationBarHidden)!
        }else{
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startupInitialisations()
        setupForNavigationBar()
        registerForNotifications()
        updateUserInterfaceOnScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupForNavigationBar()
        
    }
    
    //MARK: - other methods
    func setupForNavigationBar(){
        setAppearanceForNavigationBarType2(self.navigationController)
        setupNavigationBarTitleType2("Search on Youtube",viewController: self)
        if self.navigationController?.viewControllers.count > 1 {
            addNavigationBarButton(self, image: UIImage(named: "backarrowblack"), title: nil, isLeft: true)
        }
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func onClickOfLeftBarButton(_ sender:AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
    func registerForNotifications(){
        
    }
    
    func startupInitialisations(){
        setAppearanceForViewController(self)
        setAppearanceForTableView(tableView)
        registerNib("VideoTableViewCell", tableView: tableView)
        loadLastStatusIfRequired()
    }
    
    func updateUserInterfaceOnScreen(){
        tableView?.reloadData()
    }
    
    //MARK: - DZNEmptyDataSet Delegate & Data Source
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!{
        let attributes = [NSFontAttributeName : UIFont(name: FONT_SEMI_BOLD, size: 20)!]
        var message = ""
        if searchStatus == SearchStatus.notSearched {
            message = ""
        }
        else if searchStatus == SearchStatus.searchedWithNoResults {
            message = "No search results"
            if (isInternetConnectivityAvailable(false)==false){
                message = "Unable to perform search"
            }
        }
        else if searchStatus == SearchStatus.searchedWithResults {
            message = ""
        }
        return NSAttributedString(string: message, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!{
        let attributes = [NSFontAttributeName : UIFont(name: FONT_SEMI_BOLD, size: 14)!]
        var message = ""
        if searchStatus == SearchStatus.notSearched {
            message = "Search your Music"
        }
        else if searchStatus == SearchStatus.searchedWithNoResults {
            message = "try searching with different name"
            if (isInternetConnectivityAvailable(false)==false){
                message = MESSAGE_TEXT___FOR_NETWORK_NOT_REACHABILITY
            }
        }
        else if searchStatus == SearchStatus.searchedWithResults {
            message = ""
        }
        return NSAttributedString(string: message, attributes: attributes)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage!{
        if searchStatus == SearchStatus.notSearched {
            return UIImage(named:"searchLightGray")
        }
        else if searchStatus == SearchStatus.searchedWithNoResults {
            if (isInternetConnectivityAvailable(false)==false){
                return UIImage(named:"wifi")
            }
            return UIImage(named:"searchLightGray")
        }
        else if searchStatus == SearchStatus.searchedWithResults {
            return UIImage(named:"searchLightGray")
        }
        return nil
    }
    
    //MARK: - UITableView Delegate & Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat{
        return VideoTableViewCell.getRequiredHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell") as? VideoTableViewCell
        cell?.videoInformation = searchResults.object(at: indexPath.row) as? NSDictionary
        cell?.parentVC = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let videoInfo =  searchResults.object(at: indexPath.row) as? NSDictionary
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Action methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.length>0 {
            performSearch()
            self.tableView?.reloadEmptyDataSet()
        } else {
            self.searchStatus = SearchStatus.notSearched
            self.tableView?.reloadEmptyDataSet()
            searchResults.removeAllObjects()
            tableView?.reloadData()
        }
    }
    
    func performSearch() {
        loadFromCache()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(SearchViewController.performSearchPrivate), object: nil)
        self.perform(#selector(SearchViewController.performSearchPrivate), with: nil, afterDelay: 1.2)
    }
    
    func loadFromCache() {
        if searchBar.text?.length > 0 {
            if let cachedSearchResults = CacheManager.sharedInstance.loadObject("CACHED_SEARCH_TEXT_\(searchBar.text!)") as? NSMutableArray {
                self.setDataFromArray(cachedSearchResults)
            }
        }
    }
    
    func performSearchPrivate() {
        if (isInternetConnectivityAvailable(false)==false){
            self.searchStatus = SearchStatus.searchedWithNoResults;
            self.tableView?.reloadData()
        }else {
            self.tableView?.reloadData()
            if searchBar.text?.length > 0 {
                self.searchBar.showActivityIndicator()
                YouTubeHelper.sharedInstance.searchVideos(searchBar.text!, completion: { (returnedData) in
                    self.searchBar.hideActivityIndicator()
                    if let videos = returnedData as? NSMutableArray{
                        if videos.count > 0 {
                            CacheManager.sharedInstance.saveObject(videos, identifier: "CACHED_SEARCH_TEXT_\(self.searchBar.text!)")
                            CacheManager.sharedInstance.saveObject(self.searchBar.text, identifier: "SearchVClastSearchedText")
                            self.setDataFromArray(videos)
                            self.searchStatus = SearchStatus.searchedWithResults
                        }else{
                            self.searchStatus = SearchStatus.searchedWithNoResults
                        }
                    }
                })
            }
        }
    }
    
    func setDataFromArray(_ results:NSMutableArray?){
        self.searchResults = results!
        self.tableView?.reloadData()
    }
    
    func loadLastStatusIfRequired(){
        if let lastSearchedText = CacheManager.sharedInstance.loadObject("SearchVClastSearchedText") as? String{
            searchBar.text = lastSearchedText
            loadFromCache()
        }
    }

}
