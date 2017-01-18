//
//  SingleLabelAndSwitchTableViewCell.swift
//  
//
//  Created by Alok Singh on 07/07/16.
//
//

import Foundation
import UIKit

class SingleLabelAndSwitchTableViewCell : UITableViewCell {
    var isInitialisedOnce = false
    @IBOutlet var titleLabel : UILabel?
    @IBOutlet var controlSwitch : UISwitch?
    @IBOutlet var seperatorView : UIView?
    override func layoutSubviews() {
        super.layoutSubviews()
        startupInitialisations()
        updateUserInterfaceOnScreen()
    }
    func startupInitialisations(){
        if isInitialisedOnce == false {
            self.selectionStyle = UITableViewCellSelectionStyle.none
        }
        isInitialisedOnce = true
    }
    func updateUserInterfaceOnScreen(){
    }
}
