//
//  ApplicationSpecificConstants.h
//  Application
//
//  Created by Alok Singh on 01/07/16.
//  Copyright (c) 2016 Swan Music. All rights reserved.
//

import UIKit

//constants

let MINIMUM_LENGTH_LIMIT_USERNAME = 1
let MAXIMUM_LENGTH_LIMIT_USERNAME = 32

let MINIMUM_LENGTH_LIMIT_FIRST_NAME = 0
let MAXIMUM_LENGTH_LIMIT_FIRST_NAME = 64

let MINIMUM_LENGTH_LIMIT_PASSWORD = 1
let MAXIMUM_LENGTH_LIMIT_PASSWORD = 20

let MINIMUM_LENGTH_LIMIT_MOBILE_NUMBER = 7
let MAXIMUM_LENGTH_LIMIT_MOBILE_NUMBER = 14

let MINIMUM_LENGTH_LIMIT_EMAIL = 7
let MAXIMUM_LENGTH_LIMIT_EMAIL = 64

let PAGE_SIZE = 10
let APP_NAME = "Swan Music"
let DEVICE_TYPE = "iOS"
let APP_WEBSITE_LINK = "https://www.swanmusic.com"
let APP_ABOUT_US_PAGE_LINK = "https://www.swanmusic.com/index/about"
let APP_FAQ_PAGE_LINK = "https://www.swanmusic.com/index/faqs"
let APP_CONTACT_US_PAGE_LINK = "https://www.swanmusic.com"
let APP_TERMS_OF_USE_AND_PRIVACY_POLICY = "https://www.swanmusic.com/index/terms"
let ENABLE_LOGGING_WEB_SERVICE_RESPONSE = true
let ENABLE_LOGGING = true
let ENABLE_APPLYING_STREAMING_SETTINGS = false
let ADD_BANNER_VIEW_TAG = 7878
let ADD_BANNER_VIEW_HEIGHT = 44.0 as CGFloat


// message titles and descriptions

let MESSAGE_TEXT___FOR_NETWORK_NOT_REACHABILITY = "The Internet connection appears to be offline."
let MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY = "Connection failed!. Please try again!"
let MESSAGE_TEXT___FOR_FUNCTIONALLITY_PENDING_MESSAGE = "We are still developing this feature. Thanks for your patience"
let MESSAGE_TITLE___FOR_HOW_TO_REPORT_BUG_MESSAGE = "How to Report Bug?"
let MESSAGE_TEXT___FOR_HOW_TO_REPORT_BUG_MESSAGE = "Simply go to the screen where you find the bug and shake your device\nWe always welcome our users to help us in improving our services."

// font used in application
let FONT_BOLD = "MavenProBold"
let FONT_SEMI_BOLD = "MavenProMedium"
let FONT_REGULAR = "MavenProRegular"

let SUPPORT_EMAIL = "support@swanmusic.com"
let KEY_STORYBOARD_IDENTIFIER = "identifierToNibNameMap"

//short cuts
let APPDELEGATE = (UIApplication.shared.delegate as! AppDelegate)
let DEVICE_WIDTH  = UIScreen.main.bounds.size.width
let DEVICE_HEIGHT = UIScreen.main.bounds.size.height
let DEVICE_ID =  UIDevice.current.identifierForVendor!.uuidString
let USER_DEFAULTS = UserDefaults.standard

//colors
let APP_THEME_COLOR = UIColor(red: 252/255, green: 49/255, blue: 89/255, alpha: 1.0)
let APP_THEME_RED_COLOR = UIColor(red: 230/255, green: 112/255, blue: 99/255, alpha: 1.0)
let APP_THEME_GREEN_COLOR = UIColor(red: 22/255, green: 168/255, blue: 120/255, alpha: 1.0)
