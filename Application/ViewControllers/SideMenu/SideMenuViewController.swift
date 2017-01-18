//
//  SideMenuViewController.swift
//  Swan Music
//
//  Created by Alok Singh on 01/07/16.
//  Copyright (c) 2016 Swan Music. All rights reserved.
//


import UIKit
import GBDeviceInfo
import CTFeedback

class SideMenuViewController: UIViewController,UITextFieldDelegate {
    
    //MARK: - variables and constants
    @IBOutlet weak var optionsTableView : UITableView!
    @IBOutlet weak var trailingSpaceToSuperView : NSLayoutConstraint!
    
    var optionsArray = NSMutableArray()
    
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
        prepareOptions()
        updateUserInterfaceOnScreen()
        
    }
    
    //MARK: - other methods
    func setupForNavigationBar(){
        setAppearanceForNavigationBarType1(self.navigationController)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func registerForNotifications(){
    }
    
    func startupInitialisations(){
        setAppearanceForViewController(self)
        prepareOptions()
        registerNib("SingleLabelTableViewCell", tableView: optionsTableView)
        registerNib("AppInfoTableViewCell", tableView: optionsTableView)
        trailingSpaceToSuperView.constant = 100
    }
    
    func prepareOptions(){
        optionsArray.removeAllObjects()
        optionsArray.add("My Library")
        optionsArray.add("Recently Added")
        optionsArray.add("Playlist")
        optionsArray.add("Create Playlist")
        optionsArray.add("Support")
        optionsArray.add("Others")
        optionsTableView.reloadData()
    }
    
    func updateUserInterfaceOnScreen(){
    }
    
    //MARK: - UITableView Delegate & Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat{
        return 38
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        if optionsArray.count <= indexPath.row {
            return tableView .dequeueReusableCell(withIdentifier: "AppInfoTableViewCell") as! AppInfoTableViewCell
        }else{
            let cell = tableView .dequeueReusableCell(withIdentifier: "SingleLabelTableViewCell") as? SingleLabelTableViewCell
            cell?.titleLabel?.text = optionsArray[indexPath.row] as? String
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SingleLabelTableViewCell {
            performAnimatedClickEffectType1(cell.titleLabel!)
            let option = optionsArray[indexPath.row] as! String
            if option == "My Library" {
                AppCommonFunctions.sharedInstance.pushVC("PlaylistViewController", navigationController: self.navigationController, isRootViewController: false, animated: true, modifyObject: { (viewControllerObject) in
                    (viewControllerObject as! PlaylistViewController).playlist = DatabaseManager.sharedInstance.getMyLibraryPlaylist()
                    (viewControllerObject as! PlaylistViewController).showActions = false
                })
            }else if option == "Recently Added" {
                AppCommonFunctions.sharedInstance.pushVC("PlaylistViewController", navigationController: self.navigationController, isRootViewController: false, animated: true, modifyObject: { (viewControllerObject) in
                    (viewControllerObject as! PlaylistViewController).playlist = DatabaseManager.sharedInstance.getMyLibraryPlaylist()
                    (viewControllerObject as! PlaylistViewController).maxCountToShow = 10
                    (viewControllerObject as! PlaylistViewController).customTitle = "Recently Added"
                    (viewControllerObject as! PlaylistViewController).showActions = false
                })
            }else if option == "Create Playlist" {
                let prompt = UIAlertController(title: "Enter Playlist Name", message: "", preferredStyle: UIAlertControllerStyle.alert)
                prompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                prompt.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    let enteredText = (prompt.textFields![0] as UITextField).text
                    if validateIfNull(enteredText, identifier: "Playist Name"){
                        let information = ["name":enteredText!,"createdOn":Date()] as [String : Any]
                        if DatabaseManager.sharedInstance.addPlaylist(information) {
                            AppCommonFunctions.sharedInstance.pushVC("PlaylistViewController", navigationController: self.navigationController, isRootViewController: false, animated: true, modifyObject: { (viewControllerObject) in
                                (viewControllerObject as! PlaylistViewController).playlist = DatabaseManager.sharedInstance.getPlaylist(information)
                            })
                        }
                    }
                }))
                prompt.addTextField(configurationHandler: {(textField: UITextField!) in
                    textField.placeholder = "eg: Latest Party "
                    textField.keyboardType = UIKeyboardType.emailAddress
                })
                present(prompt, animated: true, completion: nil)
            }else if option == "Playlist" {
                AppCommonFunctions.sharedInstance.showCommonPickerScreen(DatabaseManager.sharedInstance.getAllPlaylistNames().mutableCopy() as! NSMutableArray,titleToShow: "Playlists") { (returnedData) in
                    if isNotNull(returnedData){
                        AppCommonFunctions.sharedInstance.pushVC("PlaylistViewController", navigationController: self.navigationController, isRootViewController: false, animated: true, modifyObject: { (viewControllerObject) in
                            (viewControllerObject as! PlaylistViewController).playlist = DatabaseManager.sharedInstance.getPlaylist(["name":returnedData!])
                        })
                    }
                }
            }else if option == ("Support") {
                UIActionSheet.show(in: self.view, withTitle: "Support", cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: ["Report Bugs","Feedback / Contact Us"], tap: { (actionSheet, index) -> Void in
                    if (index == 0){
                        showAlert(MESSAGE_TITLE___FOR_HOW_TO_REPORT_BUG_MESSAGE, message: MESSAGE_TEXT___FOR_HOW_TO_REPORT_BUG_MESSAGE)
                    }
                    else if (index == 1){
                        let feedbackVC = CTFeedbackViewController(topics: CTFeedbackViewController.defaultTopics(),localizedTopics: CTFeedbackViewController.defaultLocalizedTopics())
                        feedbackVC?.toRecipients = [SUPPORT_EMAIL]
                        feedbackVC?.useHTML = false
                        self.navigationController?.presentVC(UINavigationController(rootViewController: feedbackVC))
                    }
                })
            }else if option == "Others" {
                AppCommonFunctions.sharedInstance.showOtherOptionsScreen()
            }
        }
    }
}
