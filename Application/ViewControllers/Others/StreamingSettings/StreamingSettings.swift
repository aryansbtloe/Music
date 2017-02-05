//
//  StreamingSettings.swift
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


class StreamingSettingsViewController: UIViewController {
    
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
        setupNavigationBarTitleType2("Streaming",viewController: self)
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
        setAppearanceForTableView(tableView)
        registerNib("SingleLabelAndSwitchTableViewCell", tableView: tableView)
        setAppearanceForViewController(self)
    }
    
    func updateUserInterfaceOnScreen(){
        
    }
    
    //MARK: - UITableView Delegate & Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat{
        return 36
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleLabelAndSwitchTableViewCell") as? SingleLabelAndSwitchTableViewCell
        cell?.controlSwitch?.isHidden = true
        var title = ""
        
        if indexPath.row == 0{
            title = "Low"
        }else if indexPath.row == 1{
            title = "Medium"
        }else if indexPath.row == 2{
            title = "HD"
        }
        
        let attributesTitle = [NSFontAttributeName:UIFont(name: FONT_SEMI_BOLD, size: 13)!,
            NSForegroundColorAttributeName:UIColor.darkGray] as NSDictionary
        
        let attributedString = NSMutableAttributedString(string:title)
        attributedString.setAttributes(attributesTitle as? [String : AnyObject], range: NSMakeRange(0, title.length))
        cell?.titleLabel?.attributedText = attributedString
        
        let streamingSettings = CacheManager.sharedInstance.loadObject("streamingSettings") as! NSString

        if indexPath.row == 0{
            cell?.accessoryType = streamingSettings.isEqual(to: "0") ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        }else if indexPath.row == 1{
            cell?.accessoryType = streamingSettings.isEqual(to: "1") ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        }else if indexPath.row == 2{
            cell?.accessoryType = streamingSettings.isEqual(to: "2") ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SingleLabelAndSwitchTableViewCell
        performAnimatedClickEffectType1(cell!.titleLabel!)
        CacheManager.sharedInstance.saveObject("\(indexPath.row)", identifier: "streamingSettings")
        tableView.reloadData()
    }
    
    //MARK: - other functions
}
