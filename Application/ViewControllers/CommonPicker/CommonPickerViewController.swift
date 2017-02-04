//
//  CommonPickerViewController.swift
//  Swan Music
//
//  Created by Alok Singh on 07/07/16.
//  Copyright (c) 2016 Orahi. All rights reserved.
//


import UIKit
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


class CommonPickerViewController : UIViewController,UITextFieldDelegate {
    
    //MARK: - variables and constants
    @IBOutlet var tableView : UITableView?
    @IBOutlet var searchBar : UISearchBar!

    var optionList = NSMutableArray()
    var optionListCopy = NSMutableArray()
    var titleToShow = "Select"
    var completion : ACFCompletionBlock?

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
        setupNavigationBarTitleType2(titleToShow,viewController: self)
        if self.navigationController?.viewControllers.count > 1 {
            addNavigationBarButton(self, image: UIImage(named: "backarrowblack"), title: nil, isLeft: true)
        }
    }
    
    func onClickOfLeftBarButton(_ sender:AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
    func registerForNotifications(){
        
    }
    
    func startupInitialisations(){
        setAppearanceForViewController(self)
        setAppearanceForTableView(tableView)
        registerNib("SingleLabelTableViewCell", tableView: tableView)
        searchBar.returnKeyType = .done
        optionListCopy.addObjects(from: optionList as [AnyObject])
    }
    
    func updateUserInterfaceOnScreen(){
        
    }
    
    //MARK: - UITableView Delegate & Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat{
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleLabelTableViewCell") as? SingleLabelTableViewCell
        cell?.isInitialisedOnce = true
        let option = optionList.object(at: indexPath.row) as! String
        let title = option.enhancedString() ?? ""
        let attributesTitle = [NSFontAttributeName:UIFont(name: FONT_BOLD, size: 14)!,
            NSForegroundColorAttributeName:UIColor.darkGray] as NSDictionary
        let attributedString = NSMutableAttributedString(string:title)
        attributedString.setAttributes(attributesTitle as? [String : AnyObject], range: NSMakeRange(0, title.length))
        cell?.titleLabel?.attributedText = attributedString
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if completion != nil{
            completion!(optionList.object(at: indexPath.row) as AnyObject?)
            AppCommonFunctions.sharedInstance.hidePopupViewController()
        }
    }

    //MARK: - other functions
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        performSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
    }

    func performSearch() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(CommonPickerViewController.performSearchPrivate), object: nil)
        self.perform(#selector(CommonPickerViewController.performSearchPrivate), with: nil, afterDelay:0.4)
    }
    
    func performSearchPrivate() {
        if searchBar.text?.length > 0 {
            optionList.removeAllObjects()
            for o in optionListCopy {
                if (o as! NSString).lowercased.contains(searchBar.text!.lowercased()){
                    optionList.add((o as! NSString).copy())
                }
            }
        }else{
            optionList.addObjects(from: optionListCopy.copy() as! [AnyObject])
        }
        tableView?.reloadData()
    }
    
}
