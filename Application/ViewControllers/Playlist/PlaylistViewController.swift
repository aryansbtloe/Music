//
//  PlaylistViewController.swift
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


class PlaylistViewController: UIViewController,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    
    //MARK: - variables and constants
    @IBOutlet var tableView : UITableView!
    @IBOutlet var searchBar : UISearchBar!
    
    var playlist : Playlist!
    var searchStatus : SearchStatus = SearchStatus.notSearched
    var searchResults = NSMutableArray()
    var maxCountToShow = -1
    var showActions = true
    var customTitle : String?
    
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
        performSearch()
        
    }
    
    //MARK: - other methods
    func setupForNavigationBar(){
        setAppearanceForNavigationBarType2(self.navigationController)
        if isNotNull(customTitle){
            setupNavigationBarTitleType2("\(customTitle!)",viewController: self)
        }else{
            setupNavigationBarTitleType2("\(playlist.name!)",viewController: self)
        }
        if self.navigationController?.viewControllers.count > 1 {
            addNavigationBarButton(self, image: UIImage(named: "backarrowblack"), title: nil, isLeft: true)
        }
        if showActions {
            addNavigationBarButton(self, image: UIImage(named: "add"), title: nil, isLeft: false)
        }
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func onClickOfLeftBarButton(_ sender:AnyObject){
        AppCommonFunctions.sharedInstance.sideMenuController?.presentLeftMenuViewController()
    }
    
    func onClickOfRightBarButton(_ sender:AnyObject){
        AppCommonFunctions.sharedInstance.pushVC("SearchViewController", navigationController: self.navigationController, isRootViewController: false, animated: true, modifyObject: nil)
    }
    
    
    func registerForNotifications(){
        
    }
    
    func startupInitialisations(){
        setAppearanceForTableView(tableView)
        registerNib("VideoTableViewCell", tableView: tableView)
        loadLastStatusIfRequired()
        setAppearanceForViewController(self)
    }
    
    func updateUserInterfaceOnScreen(){
        tableView?.reloadData()
    }
    
    //MARK: - DZNEmptyDataSet Delegate & Data Source
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!{
        let attributes = [NSFontAttributeName : UIFont(name: FONT_SEMI_BOLD, size: 20)!]
        var message = ""
        if searchStatus == SearchStatus.notSearched {
            message = "No Videos !"
        }
        else if searchStatus == SearchStatus.searchedWithNoResults {
            message = "Oops ! No search results"
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
            message = "To begin importing some videos\nuse add button on the top"
        }
        else if searchStatus == SearchStatus.searchedWithNoResults {
            message = "try searching with different name"
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
        cell?.video = searchResults.object(at: indexPath.row) as? Video
        cell?.parentVC = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let videoInfo =  searchResults.object(at: indexPath.row) as? Video
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Action methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        performSearch()
    }
    
    func performSearch() {
        CacheManager.sharedInstance.saveObject(self.searchBar.text, identifier: "PlaylistVClastSearchedText")
        setDataFromArray(DatabaseManager.sharedInstance.searchVideo(searchBar.text,playlist: playlist).mutableCopy() as? NSMutableArray)
        if searchResults.count > 0 && searchBar.text?.length > 0 {
            self.searchStatus = SearchStatus.searchedWithResults
        }else if searchBar.text?.length > 0{
            self.searchStatus = SearchStatus.searchedWithNoResults
        }else{
            self.searchStatus = SearchStatus.notSearched
        }
        tableView.reloadEmptyDataSet()
    }
    
    func setDataFromArray(_ results:NSMutableArray?){
        if maxCountToShow > 0 {
            if results!.count > maxCountToShow {
                self.searchResults = results!.subarray(with: NSMakeRange(0, maxCountToShow)) as! NSMutableArray
            }else{
                self.searchResults = results!
            }
        }else{
            self.searchResults = results!
        }
        self.tableView?.reloadData()
        self.tableView?.reloadEmptyDataSet()
    }
    
    func loadLastStatusIfRequired(){
        if let lastSearchedText = CacheManager.sharedInstance.loadObject("PlaylistVClastSearchedText") as? String{
            searchBar.text = lastSearchedText
        }
        performSearch()
    }
}
