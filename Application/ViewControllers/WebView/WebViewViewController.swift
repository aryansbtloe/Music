//
//  WebViewViewController.swift
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


enum WorkingMode {
    case customUrl
}

class WebViewViewController: UIViewController,UITextFieldDelegate,UIWebViewDelegate {
    
    //MARK: - variables and constants
    var workingMode = WorkingMode.customUrl
    var isLoaded = false
    var customUrl: String?
    var customTitle: String?
    
    @IBOutlet var webview : UIWebView?
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupForNavigationBar()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUserInterfaceOnScreen()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        windowObject()!.hideActivityIndicator()
    }
    
    //MARK: - other methods
    func setupForNavigationBar(){
        setAppearanceForNavigationBarType2(self.navigationController)
        if self.navigationController?.viewControllers.count > 1 {
            addNavigationBarButton(self, image: UIImage(named: "backarrowblack"), title: nil, isLeft: true)
        }
        if workingMode == WorkingMode.customUrl {
            setupNavigationBarTitleType2(customTitle ?? "",viewController: self)
        }
    }
    
    func onClickOfLeftBarButton(_ sender:AnyObject){
        windowObject()!.hideActivityIndicator()
        self.navigationController?.popViewController(animated: true)
    }
    
    func registerForNotifications(){
        
    }
    
    func startupInitialisations(){
        animateWebViewAppearance()
        setAppearanceForViewController(self)
    }
    
    func updateUserInterfaceOnScreen(){
        if isLoaded {
            return
        }
        isLoaded = true
        if workingMode == WorkingMode.customUrl {
            self.webview?.loadRequest(URLRequest(url: URL(string:customUrl!)!))
        }
    }
    
    //MARK: - other functions
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        webview?.isHidden = true
        windowObject()!.showActivityIndicator()
        logMessage(request.url)
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        windowObject()!.showActivityIndicator()
        webview?.isHidden = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        animateWebViewAppearance2()
        windowObject()!.hideActivityIndicator()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        windowObject()!.hideActivityIndicator()
    }
    
    func animateWebViewAppearance(){
        webview?.isHidden = true
        self.webview?.layer.opacity = 0
        UIView.animate(withDuration: 0.6, delay:0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.webview?.layer.opacity = 1
            }, completion: nil)
    }
    func animateWebViewAppearance2(){
        webview?.isHidden = false
        self.webview?.layer.opacity = 0
        UIView.animate(withDuration: 0.3, delay:0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.webview?.layer.opacity = 1
            }, completion: nil)
    }
}
