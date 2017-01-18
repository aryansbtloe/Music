//
//  TabController.swift
//  Swan Music
//
//  Created by Alok Singh on 01/07/16.
//  Copyright (c) 2016 Swan Music. All rights reserved.
//

import UIKit

class TabController: UITabBarController {
    
    //MARK: - view controller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startupInitialisations()
        setupForNavigationBar()
        registerForNotifications()
        updateUserInterfaceOnScreen()
    }
    
    //MARK: - other methods
    func setupForNavigationBar(){
        setAppearanceForNavigationBarType1(self.navigationController)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func registerForNotifications(){
        
    }
    
    func startupInitialisations(){
        setAppearanceForViewController(self)
    }
    
    func updateUserInterfaceOnScreen(){
        setupTabs()
    }
    
    //MARK: - other functions
    
    func setupTabs(){
        let tabBarItems = self.tabBar.items
        for index in 0...2 {
            let item = tabBarItems![index] as UITabBarItem
            item.image = UIImage(named: "tabBar\(index+1)Normal")
            item.selectedImage = UIImage(named: "tabBar\(index+1)Active")
            item.titlePositionAdjustment = UIOffsetMake(0,512)
            item.imageInsets = UIEdgeInsetsMake(6, 6, -6, -6)
        }
    }
}
