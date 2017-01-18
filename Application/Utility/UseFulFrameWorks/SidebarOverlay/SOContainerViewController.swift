//
//  SOContainerViewController.swift
//  SidebarOverlay
//
//  Created by Alex Krzyżanowski on 12/23/15.
//  Copyright © 2015 Alex Krzyżanowski. All rights reserved.
//

import UIKit


open class SOContainerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    /**
     A view controller that is currently presented to user.
     
     Assign this property to any view controller, that should be presented on the top of your application.
     
     In most cases you have to set this property when user selects an item in sidebar menu:
     
     ```swift
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
     let vc = self.storyboard!.instantiateViewControllerWithIdentifier("newsScreen")
     self.so_containerViewController!.topViewController = vc
     }
     ```
     */
    open var topViewController: UIViewController? {
        get {
            return _topViewController
        }
        set {
            _topViewController?.view.removeFromSuperview()
            _topViewController?.removeFromParentViewController()
            
            _topViewController = newValue
            
            if let vc = _topViewController {
                vc.willMove(toParentViewController: self)
                self.addChildViewController(vc)
                self.view.addSubview(vc.view)
                vc.didMove(toParentViewController: self)
                
                vc.view.addGestureRecognizer(self.createPanGestureRecognizer())
            }
            
            self.bringViewToFront()
        }
    }
    
    open var viewController: UIViewController? {
        get {
            return _viewController
        }
        set {
            _viewController?.view.removeFromSuperview()
            _viewController?.removeFromParentViewController()
            
            _viewController = newValue
            
            if let vc = _viewController {
                vc.willMove(toParentViewController: self)
                self.addChildViewController(vc)
                self.view.addSubview(vc.view)
                vc.didMove(toParentViewController: self)
                
                vc.view.addGestureRecognizer(self.createPanGestureRecognizer())
                
                var menuFrame = vc.view.frame
                menuFrame.size.height = self.view.frame.size.height - viewControllerBottomIndent
                menuFrame.origin.y = menuFrame.size.height
                vc.view.frame = menuFrame
            }
            
            self.bringViewToFront()
        }
    }
    
    open var isBottomViewControllerPresented: Bool {
        get {
            guard let bottomVC = self.viewController else {
                return false
            }
            
            return bottomVC.view.frame.origin.y == BottomViewControllerOpenedBottomOffset
        }
        set {
            guard let bottomVC = self.viewController else {
                return
            }
            
            var frame = bottomVC.view.frame
            frame.origin.y = newValue ? BottomViewControllerOpenedBottomOffset : frame.size.height
            
            let animations = { () -> () in
                bottomVC.view.frame = frame
                self.contentCoverView.alpha = newValue ? 1.0 : 0.0
            }
            
            self.viewController?.viewWillAppear(false)
            
            UIView.animate(withDuration: SideViewControllerOpenAnimationDuration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: animations, completion: nil)
        }
    }
    
    open func toggle() {
        let bottomVC = self.viewController
        var frame = bottomVC!.view.frame
        frame.origin.y = (isBottomViewControllerPresented == false) ? BottomViewControllerOpenedBottomOffset : frame.size.height
        let animations = { () -> () in
            bottomVC!.view.frame = frame
            self.contentCoverView.alpha = (self.isBottomViewControllerPresented == false) ? 1.0 : 0.0
        }
        UIView.animate(withDuration: SideViewControllerOpenAnimationDuration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: animations, completion: nil)
        self.isBottomViewControllerPresented = self.viewPulledOutMoreThanHalfOfItsHeight(self.viewController!)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.contentCoverView = UIView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.contentCoverView = UIView()
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentCoverView.frame = self.view.bounds
        self.contentCoverView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        self.contentCoverView.alpha = 0.0
        
        let tapOnContentCoverViewGesture = UITapGestureRecognizer(target: self, action: #selector(SOContainerViewController.contentCoverViewClicked))
        self.contentCoverView.addGestureRecognizer(tapOnContentCoverViewGesture)
        
        let panOnContentCoverVewGesture = UIPanGestureRecognizer(target: self, action: #selector(SOContainerViewController.contentCoverViewClicked))
        self.contentCoverView.addGestureRecognizer(panOnContentCoverVewGesture)
        
        self.view.addSubview(self.contentCoverView)
    }
    
    //
    // MARK: Gesture recognizer delegate
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let panGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
        let translation = panGestureRecognizer.translation(in: self.view)
        return self.vectorIsMoreVertical(translation)
    }
    
    //
    // MARK: Internal usage
    
    let viewControllerBottomIndent: CGFloat = 88.0
    let BottomViewControllerOpenedBottomOffset: CGFloat = 88.0
    let SideViewControllerOpenAnimationDuration: TimeInterval = 0.24
    
    var _topViewController: UIViewController?
    var _viewController: UIViewController?
    
    var contentCoverView: UIView
    
    func contentCoverViewClicked() {
        if self.isBottomViewControllerPresented {
            self.isBottomViewControllerPresented = false
        }
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func moveMenu(_ panGesture: UIPanGestureRecognizer) {
        panGesture.view?.layer.removeAllAnimations()
        
        let translatedPoint = panGesture.translation(in: self.view)
        
        if panGesture.state == UIGestureRecognizerState.changed {
            if let sidebarView = self.viewController?.view {
                self.moveSidebarToVector(sidebarView, vector: translatedPoint)
            }
            
            panGesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
            
            if let view = self.viewController?.view {
                self.contentCoverView.alpha = 1.0 - abs(view.frame.origin.x) / view.frame.size.width
            }
        } else if panGesture.state == UIGestureRecognizerState.ended {
            if let sidebar = self.viewController {
                self.isBottomViewControllerPresented = self.viewPulledOutMoreThanHalfOfItsHeight(sidebar)
            }
        }
    }
    
    func bringViewToFront() {
        self.view.bringSubview(toFront: self.contentCoverView)
        
        if let vc = self.viewController {
            self.view.bringSubview(toFront: vc.view)
        }
    }
    
    func createPanGestureRecognizer() -> UIPanGestureRecognizer! {
        return UIPanGestureRecognizer.init(target: self, action: #selector(SOContainerViewController.moveMenu(_:)))
    }
    
    func vectorIsMoreVertical(_ point: CGPoint) -> Bool {
        if fabs(point.y) > fabs(point.x) {
            return true
        }
        return false
    }
    
    func viewPulledOutMoreThanHalfOfItsHeight(_ viewController: UIViewController) -> Bool {
        let frame = viewController.view.frame
        return fabs(frame.origin.y) < frame.size.height / 2
    }
    
    func moveSidebarToVector(_ sidebar: UIView, vector: CGPoint) {
        let calculatedYPosition = max(sidebar.frame.size.height / 2.0, sidebar.center.y + vector.y)
        sidebar.center = CGPoint(x: sidebar.center.x, y: calculatedYPosition)
    }
    
}
