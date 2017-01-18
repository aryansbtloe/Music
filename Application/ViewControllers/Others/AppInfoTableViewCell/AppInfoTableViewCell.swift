//
//  AppInfoTableViewCell.swift
//  Swan Music
//
//  Created by Alok Singh on 01/07/16.
//  Copyright (c) 2016 Swan Music. All rights reserved.
//

import Foundation
import UIKit


class AppInfoTableViewCell : UITableViewCell {
    
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var pictureImageView : UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        startupInitialisations()
        updateUserInterfaceOnScreen()
    }
    
    func startupInitialisations(){
        self.selectionStyle = UITableViewCellSelectionStyle.none
        setBorder(self.pictureImageView!, color: UIColor.white, width: 2, cornerRadius: (self.pictureImageView?.bounds.size.width)!/2)
        titleLabel?.font = UIFont(name: FONT_REGULAR, size:9)
    }
    
    func updateUserInterfaceOnScreen(){
        #if DEBUG
            titleLabel?.text = "Swan Music \(ez.appVersionAndBuild!) #Debug mode"
        #else
            titleLabel?.text = "Swan Music \(ez.appVersion!)"            
        #endif
    }
}
