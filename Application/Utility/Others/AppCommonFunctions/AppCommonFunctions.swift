//
//  WebServices.swift
//  Application
//
//  Created by Alok Singh on 01/07/16.
//  Copyright © 2016 Swan Music. All rights reserved.
//

//MARK: - AppCommonFunctions : This singleton class implements some app specific functions which are frequently needed in application.

import Foundation
import UIKit
import IQKeyboardManagerSwift
import GBDeviceInfo
import Fabric
import Crashlytics
import RESideMenu
import AVFoundation
import GoogleMobileAds
import XCDYouTubeKit
import UIView_draggable

//MARK: - Completion block
typealias ACFCompletionBlock = (_ returnedData :Any) ->()
typealias ACFModificationBlock = (_ viewControllerObject :Any) ->()

class AppCommonFunctions: NSObject , UITabBarControllerDelegate, RESideMenuDelegate
{

    var completionBlock: ACFCompletionBlock?
    var navigationController: UINavigationController?
    var tabBarController : UITabBarController?
    var sideMenuViewController : SideMenuViewController?
    var sideMenuController : RESideMenu?
    var videoPlayer : XCDYouTubeVideoPlayerViewController?
    var videoPlayerContainerView : UIView?

    
    static let sharedInstance : AppCommonFunctions = {
        let instance = AppCommonFunctions()
        return instance
    }()
    
    fileprivate override init() {
        
    }
    
    
    func prepareForStartUp(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?){
        setupDatabase()
        setupIQKeyboardManagerEnable()
        setupRateMyApp()
        setupOtherSettings()
        setupCrashlytics()
        showHomeScreen()
        setupForGoogleAds()
    }
    
    func setupForGoogleAds() {
    }
    
    func addAdsBanner(_ viewController:UIViewController) {
        DispatchQueue.main.async {
            viewController.view.viewWithTag(ADD_BANNER_VIEW_TAG)?.removeSubviews()
            let origin = CGPoint(x: 0.0, y: viewController.view.frame.size.height - CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height)
            let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait, origin: origin)
            viewController.view.addSubview(bannerView)
            bannerView.tag = ADD_BANNER_VIEW_TAG
            bannerView.adUnitID = "ca-app-pub-7178447751314817/8784249680"
            bannerView.rootViewController = viewController
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            bannerView.load(request)
        }
    }
    
    func setupDatabase() {
        DatabaseManager.sharedInstance.setupCoreDataDatabase()
    }
    
    func setupKeyboardNextButtonHandler(){
        NotificationCenter.default.addObserver(self, selector: Selector(("viewLoadedNotification")), name: NSNotification.Name(rawValue: "viewLoaded"), object: nil)
    }
    
    func setupIQKeyboardManagerEnable(){
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().shouldPlayInputClicks = true
    }
    
    func setupIQKeyboardManagerDisable(){
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = false
        IQKeyboardManager.sharedManager().shouldPlayInputClicks = false
    }
    
    func setupOtherSettings(){
        disableAutoCorrectionsAndTextSuggestionGlobally()
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: FONT_REGULAR, size: 13)!], for: UIControlState())
        UITabBar.appearance().selectedImageTintColor = APP_THEME_COLOR
        navigationController = APPDELEGATE.window?.rootViewController as? UINavigationController
        navigationController?.view.backgroundColor = UIColor.white
        windowObject()?.backgroundColor = UIColor.white
        if let settings = CacheManager.sharedInstance.loadObject("streamingSettings"){
        }else{
            CacheManager.sharedInstance.saveObject("0", identifier: "streamingSettings")
        }
        setupBackgroundAudioSettings()
        NotificationCenter.default.addObserver(self, selector: #selector(AppCommonFunctions.stopPlayer), name: NSNotification.Name.MPMoviePlayerWillExitFullscreen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppCommonFunctions.hidePlayer), name: NSNotification.Name.MPMoviePlayerWillEnterFullscreen, object: nil)
    }
    
    func setupBackgroundAudioSettings() {
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{
            logMessage("exception")
        }
    }
    
    func showActivityIndicatorViaNotification () -> () {
        showActivityIndicator("")
    }
    
    func hideActivityIndicatorViaNotification () -> () {
        hideActivityIndicator()
    }
    
    func setupRateMyApp(){
        RateMyApp.sharedInstance.appID = "957291553"
        RateMyApp.sharedInstance.trackAppUsage()
    }

    func hidePopupViewController(){
        self.navigationController!.dismissPopupViewController(.fade)
    }
    
    func isPopUpViewControllerShowing()->Bool {
        return self.navigationController!.isPopUpViewControllerShowing()
    }
    
    func setupCrashlytics(){
        Fabric.with([Crashlytics.self])
        updateUserInfoOnCrashlytics()
    }
    
    func updateUserInfoOnCrashlytics(){
    }
    
    func showHomeScreen(){
        tabBarController = getViewController("TabBarController") as? UITabBarController
        tabBarController?.delegate = self
        sideMenuViewController = getViewController("SideMenuViewController") as? SideMenuViewController
        sideMenuController = RESideMenu(contentViewController: tabBarController, leftMenuViewController: sideMenuViewController, rightMenuViewController: nil)
        sideMenuController?.delegate = self
        sideMenuController?.panGestureEnabled = true
        self.navigationController?.popToRootViewController(animated: false)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(self.sideMenuController!, animated: false)
        }
    }
    
    func sideMenu(_ sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!){
        menuViewController.viewWillAppear(true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
    }
    
    
    func getParsedValues(_ text:String) -> NSMutableDictionary {
        let information = NSMutableDictionary()
        let componentsLevel1 = (text as NSString).components(separatedBy: "&&")
        for componentLevel1 in componentsLevel1 {
            let componentsLevel2 = (componentLevel1 as NSString).components(separatedBy: "=")
            if componentsLevel2.count == 2 {
                information.setObject(componentsLevel2[1],forKey: componentsLevel2[0] as NSCopying )
            }
        }
        return information as NSMutableDictionary
    }
    
    func getViewController(_ identifier:NSString?)->(UIViewController){
        return storyBoardObject().instantiateViewController(withIdentifier: identifier as! String)
    }
    
    func presentVC(_ identifier:NSString? , viewController:UIViewController? , animated:Bool , modifyObject:ACFModificationBlock?){
        let vc = storyBoardObject().instantiateViewController(withIdentifier: identifier as! String)
        if let _ = modifyObject{
            modifyObject!(vc)
        }
        viewController!.present(UINavigationController(rootViewController: vc), animated: animated, completion: nil)
    }
    
    func pushVC(_ identifier:NSString?,navigationController:UINavigationController?,isRootViewController:Bool,animated:Bool,modifyObject:ACFModificationBlock?){
        let vc = storyBoardObject().instantiateViewController(withIdentifier: identifier as! String)
        if let _ = modifyObject{
            modifyObject!(vc)
        }
        if isRootViewController{
            navigationController!.setViewControllers([vc], animated: animated)
        }else{
            navigationController!.pushViewController(vc, animated: animated)
        }
    }
    
    func updateAppearanceOfTextFieldType1(_ textField:MKTextField?){
        if textField!.isFirstResponder {
            textField!.tintColor = APP_THEME_COLOR
            textField!.bottomBorderEnabled = true
            textField!.bottomBorderColor = APP_THEME_COLOR
            textField!.placeholder = textField!.placeholder
            textField!.floatingPlaceholderEnabled = true
            textField!.attributedPlaceholder = NSAttributedString(string:textField!.placeholder!,
                                                                  attributes:[NSForegroundColorAttributeName: APP_THEME_COLOR])
        }else {
            textField!.tintColor = UIColor.lightGray
            textField!.bottomBorderEnabled = true
            textField!.bottomBorderColor = UIColor.lightGray
            textField!.placeholder = textField!.placeholder
            textField!.floatingPlaceholderEnabled = true
            textField!.attributedPlaceholder = NSAttributedString(string:textField!.placeholder!,
                                                                  attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        }
    }
    
    func updateAppearanceOfTextFieldType2(_ textField:MKTextField?){
        if textField!.isFirstResponder {
            textField!.tintColor = APP_THEME_COLOR
            textField!.bottomBorderEnabled = true
            textField!.bottomBorderColor = APP_THEME_COLOR
            textField!.placeholder = textField!.placeholder
            textField!.floatingPlaceholderEnabled = false
        }else {
            textField!.tintColor = UIColor.lightGray
            textField!.bottomBorderEnabled = true
            textField!.bottomBorderColor = UIColor.lightGray
            textField!.placeholder = textField!.placeholder
            textField!.floatingPlaceholderEnabled = false
        }
    }
    
    func disableAutoCorrectionsAndTextSuggestionGlobally () {
        NotificationCenter.default.addObserver(self, selector: #selector(AppCommonFunctions.notificationWhenTextViewDidBeginEditing(_:)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppCommonFunctions.notificationWhenTextFieldDidBeginEditing(_:)), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
    }
    
    func notificationWhenTextFieldDidBeginEditing (_ notification:Notification) {
        let textField = notification.object as? UITextField
        textField?.autocorrectionType = UITextAutocorrectionType.no
    }
    
    func notificationWhenTextViewDidBeginEditing (_ notification:Notification) {
        let textView = notification.object as? UITextView
        textView?.autocorrectionType = UITextAutocorrectionType.no
    }
    
    func showOtherOptionsScreen(){
        let gapX = getRequiredPopupSideGap(#function)
        let gapY = getRequiredPopupVerticleGap(#function)
        let viewController = AppCommonFunctions.sharedInstance.getViewController("OtherOptionsViewController") as! OtherOptionsViewController
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.frame = CGRect(x: gapX,y: gapY,width: DEVICE_WIDTH-2*gapX, height: DEVICE_HEIGHT-2*gapY)
        navigationController.view.layer.cornerRadius = 6
        navigationController.view.layer.masksToBounds = true
        self.navigationController!.presentpopupViewController(navigationController, animationType: .fade, completion: { () -> Void in
        })
    }
    
    func showCommonPickerScreen(_ optionList:NSMutableArray,titleToShow:String,completion:ACFCompletionBlock?){
        let gapX = getRequiredPopupSideGap(#function)
        let gapY = getRequiredPopupVerticleGap(#function)
        let viewController = AppCommonFunctions.sharedInstance.getViewController("CommonPickerViewController") as! CommonPickerViewController
        viewController.completion = completion
        viewController.optionList = optionList.mutableCopy() as! NSMutableArray
        viewController.titleToShow = titleToShow
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.frame = CGRect(x: gapX,y: gapY,width: DEVICE_WIDTH-2*gapX, height: DEVICE_HEIGHT-2*gapY)
        navigationController.view.layer.cornerRadius = 6
        navigationController.view.layer.masksToBounds = true
        self.navigationController!.presentpopupViewController(navigationController, animationType: .fade, completion: { () -> Void in
        })
    }
    
    func getRequiredPopupVerticleGap(_ tag:String?)->(CGFloat){
        return (UIScreen.main.bounds.size.height-450)/2
    }
    
    func getRequiredPopupSideGap(_ tag:String?)->(CGFloat){
        return 10
    }
    
    let VIDEO_PLAYER_HEIGHT = 180.0 as CGFloat
    
    func hidePlayer(){
        videoPlayerContainerView!.isHidden = true
    }
    
    func stopPlayer(){
        if videoPlayer != nil {
            videoPlayer?.moviePlayer.view.removeFromSuperview()
            videoPlayer?.view.removeFromSuperview();
            videoPlayer = nil
            videoPlayerContainerView?.removeFromSuperview()
            videoPlayerContainerView = nil
        }
    }

    func playVideo(_ videoId:String,viewController:UIViewController) {
        resignKeyboard()
        stopPlayer()
        
        var frameContainer = CGRect.zero
        frameContainer.x = 0
        frameContainer.y = viewController.view.frame.size.height - VIDEO_PLAYER_HEIGHT
        frameContainer.w = DEVICE_WIDTH
        frameContainer.h = VIDEO_PLAYER_HEIGHT
        
        videoPlayerContainerView = UIView(frame: frameContainer)
        videoPlayerContainerView?.backgroundColor = UIColor.clear
        windowObject()!.addSubview(videoPlayerContainerView!)
        
        videoPlayer = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoId)
     
        let streamingSettings = CacheManager.sharedInstance.loadObject("streamingSettings") as! NSString
     
        if ENABLE_APPLYING_STREAMING_SETTINGS {
            if streamingSettings.isEqual(to: "0"){
                videoPlayer?.preferredVideoQualities = [XCDYouTubeVideoQuality.small240 as AnyObject,XCDYouTubeVideoQuality.medium360 as AnyObject,XCDYouTubeVideoQuality.HD720 as AnyObject]
            }else if streamingSettings.isEqual(to: "1"){
                videoPlayer?.preferredVideoQualities = [XCDYouTubeVideoQuality.medium360 as AnyObject,XCDYouTubeVideoQuality.small240 as AnyObject,XCDYouTubeVideoQuality.HD720 as AnyObject]
            }else if streamingSettings.isEqual(to: "2"){
                videoPlayer?.preferredVideoQualities = [XCDYouTubeVideoQuality.HD720 as AnyObject,XCDYouTubeVideoQuality.medium360 as AnyObject,XCDYouTubeVideoQuality.small240 as AnyObject]
            }
        }
        
        var framePlayer = CGRect.zero
        framePlayer.x = 0
        framePlayer.y = 0
        framePlayer.w = DEVICE_WIDTH
        framePlayer.h = VIDEO_PLAYER_HEIGHT

        videoPlayer!.view.frame = framePlayer
        videoPlayer!.present(in: videoPlayerContainerView!)
        videoPlayer!.moviePlayer.isBackgroundPlaybackEnabled = true
        videoPlayer!.moviePlayer.play()
        videoPlayerContainerView!.enableDragging()
        videoPlayer!.view.backgroundColor = UIColor.clear
        
        let b = videoPlayerContainerView!.bounds
        let closeButton = UIButton(type: .custom)
        closeButton.addTarget(self, action: #selector(AppCommonFunctions.stopPlayer), for: UIControlEvents.touchUpInside)
        closeButton.frame = CGRect(x:0, y:0, w: 30, h: 30)
        closeButton.center = b.topRight
        closeButton.centerX = closeButton.centerX - 15
        closeButton.centerY = closeButton.centerY + 15
        closeButton.backgroundColor = UIColor.white
        closeButton.setImage(UIImage(named: "closeButton"), for: UIControlState.normal)
        videoPlayerContainerView?.addSubview(closeButton)
    }
    
    func showWebViewController(_ workingMode:WorkingMode,customUrl:String?="",customTitle:String?=""){
        if isNotNull(self.navigationController) {
            let gapX = self.getRequiredPopupSideGap(#function)
            let gapY = self.getRequiredPopupVerticleGap(#function)
            let viewController = AppCommonFunctions.sharedInstance.getViewController("WebViewViewController") as! WebViewViewController
            viewController.workingMode = workingMode
            viewController.customUrl = customUrl
            viewController.customTitle = customTitle
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.view.frame = CGRect(x: gapX,y: gapY,width: DEVICE_WIDTH-2*gapX, height: DEVICE_HEIGHT-2*gapY)
            navigationController.view.layer.cornerRadius = 6
            navigationController.view.layer.masksToBounds = true
            self.navigationController!.presentpopupViewController(navigationController, animationType: .fade, completion: { () -> Void in
            })
        }
    }
}
