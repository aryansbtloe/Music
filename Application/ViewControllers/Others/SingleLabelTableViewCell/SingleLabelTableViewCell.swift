//
//  SingleLabelTableViewCell.swift
//  Swan Music
//
//  Created by Alok Singh on 01/07/16.
//  Copyright (c) 2016 Swan Music. All rights reserved.
//

import Foundation
import UIKit

class SingleLabelTableViewCell : UITableViewCell {
    var isInitialisedOnce = false
    @IBOutlet var titleLabel : UILabel?
    @IBOutlet var badgeIndicatorView : UIView?
    override func layoutSubviews() {
        super.layoutSubviews()
        startupInitialisations()
        updateUserInterfaceOnScreen()
    }
    func startupInitialisations(){
        if isInitialisedOnce == false {
            self.selectionStyle = UITableViewCellSelectionStyle.none
            self.titleLabel?.font = UIFont(name: FONT_REGULAR, size: 14)
            self.titleLabel?.textColor = UIColor.gray
        }
        isInitialisedOnce = true
    }
    func updateUserInterfaceOnScreen(){
    }
}
