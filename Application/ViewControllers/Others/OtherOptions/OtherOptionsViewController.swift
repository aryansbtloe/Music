//
//  OtherOptionsViewController.swift
//  Swan Music
//
//  Created by Alok Singh on 01/07/16.
//  Copyright (c) 2016 Swan Music. All rights reserved.
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


class OtherOptionsViewController: UIViewController,UITextFieldDelegate {
    
    //MARK: - variables and constants
    @IBOutlet var tableView : UITableView?
    
    
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
        setupNavigationBarTitleType2("Others",viewController: self)
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
        registerNib("SingleLabelTableViewCell", tableView: tableView)
        registerNib("AppInfoTableViewCell", tableView: tableView)
    }
    
    func updateUserInterfaceOnScreen(){
        
    }
    
    //MARK: - UITableView Delegate & Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat{
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 5 {
            return tableView .dequeueReusableCell(withIdentifier: "AppInfoTableViewCell") as! AppInfoTableViewCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleLabelTableViewCell") as? SingleLabelTableViewCell
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        if indexPath.row == 0{
            cell?.titleLabel?.text = "Streaming Settings"
        }
        if indexPath.row == 1{
            cell?.titleLabel?.text = "Rate Us"
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SingleLabelTableViewCell {
            performAnimatedClickEffectType1(cell.titleLabel!)
        }
        if indexPath.row == 0{
            AppCommonFunctions.sharedInstance.pushVC("StreamingSettingsViewController", navigationController: self.navigationController, isRootViewController: false, animated: true, modifyObject: { (viewControllerObject) in
                
            })
        }else if indexPath.row == 1{
            RateMyApp.sharedInstance.showRatingAlert()
        }
    }
    
    //MARK: - other functions
    
}
