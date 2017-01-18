import UIKit
import CoreLocation
import MapKit
import Foundation
import QuartzCore

// MARK: - Attributed String

public extension NSAttributedString {
    func heightWithConstrainedWidth(_ width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        return ceil(boundingBox.height)
    }
}

// MARK: - UILabel

public extension UILabel{
    func requiredHeight() -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}

// MARK: - UIImage

public extension UIImage {
    
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
    convenience init(scrollView: UIScrollView) {
        let initialScrollViewFrame = scrollView.frame as CGRect
        let initialContentOffset = scrollView.contentOffset as CGPoint
        
        scrollView.contentOffset = CGPoint.zero;
        scrollView.frame = CGRect(x: 0,y: 0,width: scrollView.contentSize.width,height: scrollView.contentSize.height);
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, false, UIScreen.main.scale)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        scrollView.frame = initialScrollViewFrame
        scrollView.contentOffset = initialContentOffset
        self.init(cgImage: image!.cgImage!)
    }
    
    static func fromColor(_ color: UIColor ,size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}

// MARK: - String

public extension String {
    
    /// EZSE: Cut string from integerIndex to the end
    public subscript(integerIndex: Int) -> Character {
        let index = characters.index(startIndex, offsetBy: integerIndex)
        return self[index]
    }
    
    /// EZSE: Cut string from range
    public subscript(integerRange: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: integerRange.lowerBound)
        let end = characters.index(startIndex, offsetBy: integerRange.upperBound)
        let range = start..<end
        return self[range]
    }
    
    /// EZSE: Counts number of instances of the input inside String
    public func count(_ substring: String) -> Int {
        return components(separatedBy: substring).count - 1
    }
    
    /// EZSE: Capitalizes first character of String
    public var capitalizeFirst: String {
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).capitalized)
        return result
    }
    
    /// EZSE: Counts whitespace & new lines
    public func isOnlyEmptySpacesAndNewLineCharacters() -> Bool {
        let characterSet = CharacterSet.whitespacesAndNewlines
        let newText = self.trimmingCharacters(in: characterSet)
        return newText.isEmpty
    }
    
    /// EZSE: Trims white space and new line characters
    public mutating func trim() {
        self = self.trimmed()
    }
    
    /// EZSE: Trims white space and new line characters, returns a new string
    public func trimmed() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// EZSE: Checks if String contains Email
    public var isEmail: Bool {
        let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let firstMatch = dataDetector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: length))
        return (firstMatch?.range.location != NSNotFound && firstMatch?.url?.scheme == "mailto")
    }
    
    /// EZSE: Returns if String is a number
    public func isNumber() -> Bool {
        if let _ = NumberFormatter().number(from: self) {
            return true
        }
        return false
    }
    
    /// EZSE: Extracts URLS from String
    public var extractURLs: [URL] {
        var urls: [URL] = []
        let detector: NSDataDetector?
        do {
            detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        } catch _ as NSError {
            detector = nil
        }
        
        let text = self
        
        if let detector = detector {
            detector.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.characters.count), using: {
                (result: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                if let result = result, let url = result.url {
                    urls.append(url)
                }
            })
        }
        
        return urls
    }
    
    /// EZSE: Checking if String contains input
    public func contains(_ find: String) -> Bool {
        return self.range(of: find) != nil
    }
    
    /// EZSE: Checking if String contains input with comparing options
    public func contains(_ find: String, compareOption: NSString.CompareOptions) -> Bool {
        return self.range(of: find, options: compareOption) != nil
    }
    
    /// EZSE: Converts String to Int
    public func toInt() -> Int {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return 0
        }
    }
    
    /// EZSE: Converts String to Double
    public func toDouble() -> Double {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return 0.0
        }
    }
    
    /// EZSE: Converts String to Float
    public func toFloat() -> Float {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return 0.0
        }
    }
    
    /// EZSE: Converts String to Bool
    public func toBool() -> Bool? {
        let trimmed = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        if trimmed == "true" || trimmed == "false" {
            return (trimmed as NSString).boolValue
        }
        return nil
    }
    
    ///EZSE: Returns the first index of the occurency of the character in String
    public func getIndexOf(_ char: Character) -> Int? {
        for (index, c) in characters.enumerated() {
            if c == char {
                return index
            }
        }
        return nil
    }
    
    /// EZSE: Converts String to NSString
    public var toNSString: NSString { get { return self as NSString } }
    
    #if os(iOS)
    
    ///EZSE: Returns bold NSAttributedString
    public func bold() -> NSAttributedString {
        let boldString = NSMutableAttributedString(string: self, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)])
        return boldString
    }
    
    #endif
    
    ///EZSE: Returns underlined NSAttributedString
    public func underline() -> NSAttributedString {
        let underlineString = NSAttributedString(string: self, attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        return underlineString
    }
    
    #if os(iOS)
    
    ///EZSE: Returns italic NSAttributedString
    public func italic() -> NSAttributedString {
        let italicString = NSMutableAttributedString(string: self, attributes: [NSFontAttributeName: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)])
        return italicString
    }
    
    /// EZSE: Returns strikehthrough NSAttributedString
    public func strikethrough() -> NSAttributedString {
        let italicString = NSMutableAttributedString(string: self, attributes: [
            NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int)])
        return italicString
    }
    
    #endif
    
    ///EZSE: Returns NSAttributedString
    public func color(_ color: UIColor) -> NSAttributedString {
        let colorString = NSMutableAttributedString(string: self, attributes: [NSForegroundColorAttributeName: color])
        return colorString
    }
    
    /// EZSE: Checks if String contains Emoji
    public func includesEmoji() -> Bool {
        for i in 0...length {
            let c: unichar = (self as NSString).character(at: i)
            if (0xD800 <= c && c <= 0xDBFF) || (0xDC00 <= c && c <= 0xDFFF) {
                return true
            }
        }
        return false
    }
    
    var length: Int { return (self as NSString).length }
    
    func heightWithConstrainedWidth(_ width: CGFloat,maxHeight: CGFloat, font: UIFont) -> CGRect {
        let constraintRect = CGSize(width: width, height: maxHeight)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox
    }
    
    func indexOf(_ target: String) -> Int? {
        let range = (self as NSString).range(of: target)
        guard range.toRange() != nil else {
            return nil
        }
        return range.location
    }
    
    func lastIndexOf(_ target: String) -> Int? {
        let range = (self as NSString).range(of: target, options: NSString.CompareOptions.backwards)
        guard range.toRange() != nil else {
            return nil
        }
        return self.length - range.location - 1
        
    }
    
    func trimmedString()->String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func chopPrefix(_ count: Int = 1) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return self.substring(to: self.characters.index(self.endIndex, offsetBy: -count))
    }
    
    func enhancedString()->String {
        var string = self
        let pattern = "^\\s+|\\s+$|\\s+(?=\\s)"
        string = string.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        string = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return string.capitalized
    }
    
    func firstName()->String {
        let string = self
        let components = string.components(separatedBy: " ")
        if (components as NSArray).count > 0{
            return components[0]
        }
        return string
    }
    
    func asNSURL()->URL {
        return URL(string: self.addingPercentEscapes(using: String.Encoding.utf8)!)!
    }
    
    func aURLReady()->String {
        return self.addingPercentEscapes(using: String.Encoding.utf8)!
    }
    
    mutating func separateStringWithCaps(){
        var index = 1
        let mutableString = NSMutableString(string: self)
        while(index < mutableString.length){
            if CharacterSet.uppercaseLetters.contains(UnicodeScalar(mutableString.character(at: index))!){
                mutableString.insert(" ", at: index)
                index += 1
            }
            index += 1
        }
        self = String(mutableString)
    }
    
    func dateValue()->Date{
        var date : Date?
        if isNotNull(self){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = dateFormatter.date(from: self)!
        }
        return date!
    }

    func dateUsingFormat(format:String)->Date{
        var date : Date?
        if isNotNull(self){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            date = dateFormatter.date(from: self)!
        }
        return date!
    }

    func dateValueFromMilliSeconds()->Date{
        return Date(timeIntervalSince1970:self.toDouble())
    }
    
    func dateValueType1()->Date{
        var date : Date?
        if isNotNull(self){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            date = dateFormatter.date(from: self)
            if isNull(date){
                dateFormatter.dateFormat = "dd-MM-yyyy"
                date = dateFormatter.date(from: self)
            }
            if isNull(date){
                dateFormatter.dateFormat = "dd MM yyyy"
                date = dateFormatter.date(from: self)
            }
            if isNull(date){
                dateFormatter.dateFormat = "yyyy MM dd"
                date = dateFormatter.date(from: self)
            }
        }
        if isNull(date){
            return Date()
        }
        return date!
    }
    
    public func substring(_ from:Int = 0, to:Int = -1) -> String {
        var to = to
        if to < 0 {
            to = self.length + to
        }
        return self.substring(with: (self.characters.index(self.startIndex, offsetBy: from) ..< self.characters.index(self.startIndex, offsetBy: to+1)))
    }
    
    public func substring(_ from:Int = 0, length:Int) -> String {
        return self.substring(with: (self.characters.index(self.startIndex, offsetBy: from) ..< self.characters.index(self.startIndex, offsetBy: from+length)))
    }
    
    func stringHHMMSSToHHMMA()->String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var date = dateFormatter.date(from: self)
        if date == nil {
            dateFormatter.dateFormat = "HH:mm:ss"
            date = dateFormatter.date(from: self)
        }
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date!)
    }
    
    func stringHHMMAToHHMM()->String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date!)
    }
}

public struct ez {
    /// EZSE: Returns app's name
    public static var appDisplayName: String? {
        if let bundleDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return bundleDisplayName
        } else if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        }
        
        return nil
    }
    
    /// EZSE: Returns app's version number
    public static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    /// EZSE: Return app's build number
    public static var appBuild: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
    /// EZSE: Returns both app's version and build numbers "v0.3(7)"
    public static var appVersionAndBuild: String? {
        if appVersion != nil && appBuild != nil {
            if appVersion == appBuild {
                return "v\(appVersion!)"
            } else {
                return "v\(appVersion!)(\(appBuild!))"
            }
        }
        return nil
    }
    
    /// EZSE: Return device version ""
    public static var deviceVersion: String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    /// EZSE: Returns true if DEBUG mode is active //TODO: Add to readme
    public static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    /// EZSE: Returns true if RELEASE mode is active //TODO: Add to readme
    public static var isRelease: Bool {
        #if DEBUG
            return false
        #else
            return true
        #endif
    }
    
    /// EZSE: Returns true if its simulator and not a device //TODO: Add to readme
    public static var isSimulator: Bool {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return true
        #else
            return false
        #endif
    }
    
    /// EZSE: Returns true if its on a device and not a simulator //TODO: Add to readme
    public static var isDevice: Bool {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return false
        #else
            return true
        #endif
    }
    
    /// EZSE: Returns the top ViewController
    public static var topMostVC: UIViewController? {
        var presentedVC = UIApplication.shared.keyWindow?.rootViewController
        while let pVC = presentedVC?.presentedViewController {
            presentedVC = pVC
        }
        
        if presentedVC == nil {
            print("EZSwiftExtensions Error: You don't have any views set. You may be calling them in viewDidLoad. Try viewDidAppear instead.")
        }
        return presentedVC
    }
    
    #if os(iOS)
    
    /// EZSE: Returns current screen orientation
    public static var screenOrientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    
    #endif
    
    /// EZSwiftExtensions
    public static var horizontalSizeClass: UIUserInterfaceSizeClass {
        return self.topMostVC?.traitCollection.horizontalSizeClass ?? UIUserInterfaceSizeClass.unspecified
    }
    
    /// EZSwiftExtensions
    public static var verticalSizeClass: UIUserInterfaceSizeClass {
        return self.topMostVC?.traitCollection.verticalSizeClass ?? UIUserInterfaceSizeClass.unspecified
    }
    
    /// EZSE: Returns screen width
    public static var screenWidth: CGFloat {
        
        #if os(iOS)
            
            if UIInterfaceOrientationIsPortrait(screenOrientation) {
                return UIScreen.main.bounds.size.width
            } else {
                return UIScreen.main.bounds.size.height
            }
            
        #elseif os(tvOS)
            
            return UIScreen.mainScreen().bounds.size.width
            
        #endif
    }
    
    /// EZSE: Returns screen height
    public static var screenHeight: CGFloat {
        
        #if os(iOS)
            
            if UIInterfaceOrientationIsPortrait(screenOrientation) {
                return UIScreen.main.bounds.size.height
            } else {
                return UIScreen.main.bounds.size.width
            }
            
        #elseif os(tvOS)
            
            return UIScreen.mainScreen().bounds.size.height
            
        #endif
    }
    
    #if os(iOS)
    
    /// EZSE: Returns StatusBar height
    public static var screenStatusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    /// EZSE: Return screen's height without StatusBar
    public static var screenHeightWithoutStatusBar: CGFloat {
        if UIInterfaceOrientationIsPortrait(screenOrientation) {
            return UIScreen.main.bounds.size.height - screenStatusBarHeight
        } else {
            return UIScreen.main.bounds.size.width - screenStatusBarHeight
        }
    }
    
    #endif
    
    //    /// EZSE: Returns the locale country code. An example value might be "ES". //TODO: Add to readme
    //    public static var currentRegion: String? {
    //        return (Locale.current as NSLocale).object(forKey: Locale.Key.countryCode) as? String
    //    }
    
    /// EZSE: Calls action when a screen shot is taken
    public static func detectScreenShot(_ action: @escaping () -> ()) {
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil, queue: mainQueue) { notification in
            // executes after screenshot
            action()
        }
    }
    
    // MARK: - Dispatch
    
    
    /// EZSE: Runs function after x seconds
    public static func runThisAfterDelay(seconds: Double, after: @escaping () -> ()) {
        runThisAfterDelay(seconds: seconds, queue: DispatchQueue.main, after: after)
    }
    
    //TODO: Make this easier
    /// EZSE: Runs function after x seconds with dispatch_queue, use this syntax: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
    public static func runThisAfterDelay(seconds: Double, queue: DispatchQueue, after: @escaping ()->()) {
        let time = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        queue.asyncAfter(deadline: time, execute: after)
    }
    
    /// EZSE: Submits a block for asynchronous execution on the main queue
    public static func runThisInMainThread(_ block: @escaping ()->()) {
        DispatchQueue.main.async(execute: block)
    }
    
    /// EZSE: Runs in Default priority queue
    public static func runThisInBackground(_ block: @escaping () -> ()) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: block)
    }
}

extension Double {
    /// EZSE: Converts Double to String
    public var toString: String { return String(self) }
    /// EZSE: Converts Double to Int
    public var toInt: Int { return Int(self) }
    
}

extension UIImage {
    /// EZSE: Returns compressed image to rate from 0 to 1
    public func compressImage(_ rate: CGFloat) -> Data? {
        return UIImageJPEGRepresentation(self, rate)
    }
    
    /// EZSE: Returns Image size in Bytes
    public func getSizeAsBytes() -> Int {
        return UIImageJPEGRepresentation(self, 1)!.count ?? 0
    }
    
    /// EZSE: Returns Image size in Kylobites
    public func getSizeAsKilobytes() -> Int {
        let sizeAsBytes = getSizeAsBytes()
        return sizeAsBytes != 0 ? sizeAsBytes / 1024 : 0
    }
    
    /// EZSE: scales image
    public class func scaleTo(_ image: UIImage, w: CGFloat, h: CGFloat) -> UIImage {
        let newSize = CGSize(width: w, height: h)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// EZSE Returns resized image with width. Might return low quality
    public func resizeWithWidth(_ width: CGFloat) -> UIImage {
        let aspectSize = CGSize (width: width, height: aspectHeightForWidth(width))
        
        UIGraphicsBeginImageContext(aspectSize)
        self.draw(in: CGRect(origin: CGPoint.zero, size: aspectSize))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
    /// EZSE Returns resized image with height. Might return low quality
    public func resizeWithHeight(_ height: CGFloat) -> UIImage {
        let aspectSize = CGSize (width: aspectWidthForHeight(height), height: height)
        
        UIGraphicsBeginImageContext(aspectSize)
        self.draw(in: CGRect(origin: CGPoint.zero, size: aspectSize))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
    /// EZSE:
    public func aspectHeightForWidth(_ width: CGFloat) -> CGFloat {
        return (width * self.size.height) / self.size.width
    }
    
    /// EZSE:
    public func aspectWidthForHeight(_ height: CGFloat) -> CGFloat {
        return (height * self.size.width) / self.size.height
    }
    
    ///EZSE: Returns the image associated with the URL
    public convenience init?(urlString: String) {
        guard let url = URL(string: urlString) else {
            self.init(data: Data())
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            print("EZSE: No image in URL \(urlString)")
            self.init(data: Data())
            return
        }
        self.init(data: data)
    }
    
    ///EZSE: Returns an empty image //TODO: Add to readme
    public class func blankImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIButton {
    /// EZSwiftExtensions
    
    // swiftlint:disable function_parameter_count
    public convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, target: AnyObject, action: Selector) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
        addTarget(target, action: action, for: UIControlEvents.touchUpInside)
    }
    // swiftlint:enable function_parameter_count
    
    /// EZSwiftExtensions
    public func setBackgroundColor(_ color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}


extension UISwitch {
    public func toggle() {
        self.setOn(!self.isOn, animated: true)
    }
}

// MARK: - Float

public extension Float {
    
    public static func random(_ lower: Float = 0, _ upper: Float = 100) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
    
    func toInt() -> Int? {
        if self > Float(Int.min) && self < Float(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
    
}

// MARK: - Date

let DefaultFormat = "EEE MMM dd HH:mm:ss Z yyyy"
let RSSFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
let AltRSSFormat = "d MMM yyyy HH:mm:ss ZZZ"

public enum ISO8601Format: String {
    case Year = "yyyy" // 1997
    case YearMonth = "yyyy-MM" // 1997-07
    case Date = "yyyy-MM-dd" // 1997-07-16
    case DateTime = "yyyy-MM-dd'T'HH:mmZ" // 1997-07-16T19:20+01:00
    case DateTimeSec = "yyyy-MM-dd'T'HH:mm:ssZ" // 1997-07-16T19:20:30+01:00
    case DateTimeMilliSec = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 1997-07-16T19:20:30.45+01:00
    init(dateString:String) {
        switch dateString.characters.count {
        case 4:
            self = ISO8601Format(rawValue: ISO8601Format.Year.rawValue)!
        case 7:
            self = ISO8601Format(rawValue: ISO8601Format.YearMonth.rawValue)!
        case 10:
            self = ISO8601Format(rawValue: ISO8601Format.Date.rawValue)!
        case 22:
            self = ISO8601Format(rawValue: ISO8601Format.DateTime.rawValue)!
        case 25:
            self = ISO8601Format(rawValue: ISO8601Format.DateTimeSec.rawValue)!
        default:// 28:
            self = ISO8601Format(rawValue: ISO8601Format.DateTimeMilliSec.rawValue)!
        }
    }
}

public enum DateFormat {
    case iso8601(ISO8601Format?), dotNet, rss, altRSS, custom(String)
}

public enum TimeZone {
    case local, utc
}

extension Date {
    
        /// EZSE: Initializes NSDate from string and format
        public init?(fromString string: String, format: String) {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                self = Date.init(timeInterval: 0, since: date)
            } else {
                return nil
            }
        }
        
        /// EZSE: Calculates how many days passed from now to date
        public func daysInBetweenDate(_ date: Date) -> Double {
            var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
            diff = fabs(diff/86400)
            return diff
        }
        
        /// EZSE: Calculates how many hours passed from now to date
        public func hoursInBetweenDate(_ date: Date) -> Double {
            var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
            diff = fabs(diff/3600)
            return diff
        }
        
        /// EZSE: Calculates how many minutes passed from now to date
        public func minutesInBetweenDate(_ date: Date) -> Double {
            var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
            diff = fabs(diff/60)
            return diff
        }
        
        /// EZSE: Calculates how many seconds passed from now to date
        public func secondsInBetweenDate(_ date: Date) -> Double {
            var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
            diff = fabs(diff)
            return diff
        }
        
        /// EZSE: Easy creation of time passed String. Can be Years, Months, days, hours, minutes or seconds
        public func timePassed() -> String {
            let date = Date()
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: self, to: date, options: [])
            var str: String
            
            if components.year! >= 1 {
                components.year == 1 ? (str = "year") : (str = "years")
                return "\(components.year) \(str) ago"
            } else if components.month! >= 1 {
                components.month == 1 ? (str = "month") : (str = "months")
                return "\(components.month) \(str) ago"
            } else if components.day! >= 1 {
                components.day == 1 ? (str = "day") : (str = "days")
                return "\(components.day) \(str) ago"
            } else if components.hour! >= 1 {
                components.hour == 1 ? (str = "hour") : (str = "hours")
                return "\(components.hour) \(str) ago"
            } else if components.minute! >= 1 {
                components.minute == 1 ? (str = "minute") : (str = "minutes")
                return "\(components.minute) \(str) ago"
            } else if components.second == 0 {
                return "Just now"
            } else {
                return "\(components.second) seconds ago"
            }
        }
        
        /// EZSE: Converts NSDate to String
        public func toStringValue(_ dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = dateStyle
            formatter.timeStyle = timeStyle
            return formatter.string(from: self)
        }
        
        /// EZSE: Converts NSDate to String, with format
        public func toStringValue(_ format: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.string(from: self)
        }
    
    /// EZSE: Returns if dates are equal to each other
    static public func == (lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == .orderedSame
    }
    /// EZSE: Returns if one date is smaller than the other
    static public func < (lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == .orderedAscending
    }
    
    static public func > (lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == .orderedDescending
    }

    func stringValue()->String{
        return self.toStringValue("yyyy-MM-dd'T'HH:mm:ssZ")
    }
    
    func stringTimeOnly_AM_PM_FormatValue()->String{
        return self.toStringValue("h:mm a")
    }
    
    func stringTimeOnly24HFormatValue()->String{
        return self.toStringValue("HH:mm:ss")
    }

    
    // MARK: Intervals In Seconds
    fileprivate static func minuteInSeconds() -> Double { return 60 }
    fileprivate static func hourInSeconds() -> Double { return 3600 }
    fileprivate static func dayInSeconds() -> Double { return 86400 }
    fileprivate static func weekInSeconds() -> Double { return 604800 }
    fileprivate static func yearInSeconds() -> Double { return 31556926 }
    
    // MARK: Components
    fileprivate static func componentFlags() -> NSCalendar.Unit { return [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.weekday, NSCalendar.Unit.weekdayOrdinal, NSCalendar.Unit.weekOfYear] }
    
    fileprivate static func components(_ fromDate: Date) -> DateComponents! {
        return (Calendar.current as NSCalendar).components(Date.componentFlags(), from: fromDate)
    }
    
    fileprivate func components() -> DateComponents  {
        return Date.components(self)!
    }
    
    func since() -> String {
        let seconds = abs(Date().timeIntervalSince1970 - self.timeIntervalSince1970)
        if seconds <= 120 {
            return "just now"
        }
        let minutes = Int(floor(seconds / 60))
        if minutes <= 60 {
            return "\(minutes) mins ago"
        }
        let hours = minutes / 60
        if hours <= 24 {
            return "\(hours) hrs ago"
        }
        if hours <= 48 {
            return "yesterday"
        }
        let days = hours / 24
        if days <= 30 {
            return "\(days) days ago"
        }
        if days <= 14 {
            return "last week"
        }
        let months = days / 30
        if months == 1 {
            return "last month"
        }
        if months <= 12 {
            return "\(months) months ago"
        }
        let years = months / 12
        if years == 1 {
            return "last year"
        }
        return "\(years) years ago"
    }
    
    func isEqualToDateIgnoringTime(_ date: Date) -> Bool
    {
        let comp1 = Date.components(self)
        let comp2 = Date.components(date)
        return ((comp1!.year == comp2!.year) && (comp1!.month == comp2!.month) && (comp1!.day == comp2!.day))
    }
    
    func isToday() -> Bool
    {
        return self.isEqualToDateIgnoringTime(Date())
    }
    
    func isTomorrow() -> Bool
    {
        return self.isEqualToDateIgnoringTime(Date().dateByAddingDays(1))
    }
    
    func isYesterday() -> Bool
    {
        return self.isEqualToDateIgnoringTime(Date().dateBySubtractingDays(1))
    }
    
    func isSameWeekAsDate(_ date: Date) -> Bool
    {
        let comp1 = Date.components(self)
        let comp2 = Date.components(date)
        // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
        if comp1?.weekOfYear != comp2?.weekOfYear {
            return false
        }
        // Must have a time interval under 1 week
        return abs(self.timeIntervalSince(date)) < Date.weekInSeconds()
    }
    
    func isThisWeek() -> Bool
    {
        return self.isSameWeekAsDate(Date())
    }
    
    func isNextWeek() -> Bool
    {
        let interval: TimeInterval = Date().timeIntervalSinceReferenceDate + Date.weekInSeconds()
        let date = Date(timeIntervalSinceReferenceDate: interval)
        return self.isSameWeekAsDate(date)
    }
    
    func isLastWeek() -> Bool
    {
        let interval: TimeInterval = Date().timeIntervalSinceReferenceDate - Date.weekInSeconds()
        let date = Date(timeIntervalSinceReferenceDate: interval)
        return self.isSameWeekAsDate(date)
    }
    
    func isSameYearAsDate(_ date: Date) -> Bool
    {
        let comp1 = Date.components(self)
        let comp2 = Date.components(date)
        return (comp1!.year == comp2!.year)
    }
    
    func isThisYear() -> Bool
    {
        return self.isSameYearAsDate(Date())
    }
    
    func isNextYear() -> Bool
    {
        let comp1 = Date.components(self)
        let comp2 = Date.components(Date())
        return (comp1!.year! == comp2!.year! + 1)
    }
    
    func isLastYear() -> Bool
    {
        let comp1 = Date.components(self)
        let comp2 = Date.components(Date())
        return (comp1!.year! == comp2!.year! - 1)
    }
    
    func isEarlierThanDate(_ date: Date) -> Bool
    {
        return self.compare(date) == .orderedAscending
    }
    
    func isLaterThanDate(_ date: Date) -> Bool
    {
        return self.compare(date) == .orderedDescending
    }
    
    func isInFuture() -> Bool
    {
        return self.isLaterThanDate(Date())
    }
    
    func isInPast() -> Bool
    {
        return self.isEarlierThanDate(Date())
    }
    
    func dateByAddingDays(_ days: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.day = days
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func dateBySubtractingDays(_ days: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.day = (days * -1)
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func dateByAddingHours(_ hours: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.hour = hours
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func dateBySubtractingHours(_ hours: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.hour = (hours * -1)
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func dateByAddingMinutes(_ minutes: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.minute = minutes
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func dateBySubtractingMinutes(_ minutes: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.minute = (minutes * -1)
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func dateByAddingSeconds(_ seconds: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.second = seconds
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func dateBySubtractingSeconds(_ seconds: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.second = (seconds * -1)
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func dateAtStartOfDay() -> Date
    {
        var components = self.components()
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }
    
    func dateAtEndOfDay() -> Date
    {
        var components = self.components()
        components.hour = 23
        components.minute = 59
        components.second = 59
        return Calendar.current.date(from: components)!
    }
    
    func dateAtStartOfWeek() -> Date
    {
        let flags :NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.weekday]
        var components = (Calendar.current as NSCalendar).components(flags, from: self)
        components.weekday = Calendar.current.firstWeekday
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }
    
    func dateAtEndOfWeek() -> Date
    {
        let flags :NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.weekday]
        var components = (Calendar.current as NSCalendar).components(flags, from: self)
        components.weekday = Calendar.current.firstWeekday + 6
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }
    
    func dateAtTheStartOfMonth() -> Date
    {
        var components = self.components()
        components.day = 1
        let firstDayOfMonthDate :Date = Calendar.current.date(from: components)!
        return firstDayOfMonthDate
    }
    
    func dateAtTheEndOfMonth() -> Date {
        var components = self.components()
        components.month = components.month! + 1
        components.day = 0
        let lastDayOfMonth :Date = Calendar.current.date(from: components)!
        return lastDayOfMonth
    }
    
    static func tomorrow() -> Date
    {
        return Date().dateByAddingDays(1).dateAtStartOfDay()
    }
    
    static func yesterday() -> Date
    {
        return Date().dateBySubtractingDays(1).dateAtStartOfDay()
    }
    
    func setTimeOfDate(_ hour: Int, minute: Int, second: Int) -> Date {
        var components = self.components()
        components.hour = hour
        components.minute = minute
        components.second = second
        return Calendar.current.date(from: components)!
    }
    
    func secondsAfterDate(_ date: Date) -> Int {
        return Int(self.timeIntervalSince(date))
    }
    
    func secondsBeforeDate(_ date: Date) -> Int {
        return Int(date.timeIntervalSince(self))
    }
    
    func minutesAfterDate(_ date: Date) -> Int {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.minuteInSeconds())
    }
    
    func minutesBeforeDate(_ date: Date) -> Int {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.minuteInSeconds())
    }
    
    func hoursAfterDate(_ date: Date) -> Int {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.hourInSeconds())
    }
    
    func hoursBeforeDate(_ date: Date) -> Int {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.hourInSeconds())
    }
    
    func daysAfterDate(_ date: Date) -> Int {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.dayInSeconds())
    }
    
    func daysBeforeDate(_ date: Date) -> Int {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.dayInSeconds())
    }
    
    func nearestHour () -> Int {
        let halfHour = Date.minuteInSeconds() * 30
        var interval = self.timeIntervalSinceReferenceDate
        if  self.seconds() < 30 {
            interval -= halfHour
        } else {
            interval += halfHour
        }
        let date = Date(timeIntervalSinceReferenceDate: interval)
        return date.hour()
    }
    
    func year () -> Int { return self.components().year!  }
    
    func month () -> Int { return self.components().month! }
    
    func week () -> Int { return self.components().weekOfYear! }
    
    func day () -> Int { return self.components().day! }
    
    func hour () -> Int { return self.components().hour! }
    
    func minute () -> Int { return self.components().minute! }
    
    func seconds () -> Int { return self.components().second! }
    
    func weekday () -> Int { return self.components().weekday! }
    
    func nthWeekday () -> Int { return self.components().weekdayOrdinal! }
    
    func monthDays () -> Int { return (Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self).length }
    
    func firstDayOfWeek () -> Int {
        let distanceToStartOfWeek = Date.dayInSeconds() * Double(self.components().weekday! - 1)
        let interval: TimeInterval = self.timeIntervalSinceReferenceDate - distanceToStartOfWeek
        return Date(timeIntervalSinceReferenceDate: interval).day()
    }
    
    func lastDayOfWeek () -> Int {
        let distanceToStartOfWeek = Date.dayInSeconds() * Double(self.components().weekday! - 1)
        let distanceToEndOfWeek = Date.dayInSeconds() * Double(7)
        let interval: TimeInterval = self.timeIntervalSinceReferenceDate - distanceToStartOfWeek + distanceToEndOfWeek
        return Date(timeIntervalSinceReferenceDate: interval).day()
    }
    
    func isWeekday() -> Bool {
        return !self.isWeekend()
    }
    
    func isWeekend() -> Bool {
        let range = (Calendar.current as NSCalendar).maximumRange(of: NSCalendar.Unit.weekday)
        return (self.weekday() == range.location || self.weekday() == range.length)
    }
    
    func toString(_ format: DateFormat, timeZone: TimeZone = .local) -> String{
        var dateFormat: String
        let zone: Foundation.TimeZone
        switch format {
        case .dotNet:
            let offset = NSTimeZone.default.secondsFromGMT() / 3600
            let nowMillis = 1000 * self.timeIntervalSince1970
            return  "/Date(\(nowMillis)\(offset))/"
        case .iso8601(let isoFormat):
            dateFormat = (isoFormat != nil) ? isoFormat!.rawValue : ISO8601Format.DateTimeMilliSec.rawValue
            zone = Foundation.TimeZone.autoupdatingCurrent
        case .rss:
            dateFormat = RSSFormat
            zone = Foundation.TimeZone.autoupdatingCurrent
        case .altRSS:
            dateFormat = AltRSSFormat
            zone = Foundation.TimeZone.autoupdatingCurrent
        case .custom(let string):
            switch timeZone {
            case .local:
                zone = Foundation.TimeZone.autoupdatingCurrent
            case .utc:
                zone = Foundation.TimeZone(secondsFromGMT: 0)!
            }
            dateFormat = string
        }
        
        let formatter = Date.formatter(dateFormat, timeZone: zone)
        return formatter.string(from: self)
    }
    
    func toString(_ dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, doesRelativeDateFormatting: Bool = false, timeZone: Foundation.TimeZone = Foundation.TimeZone.autoupdatingCurrent, locale: Locale = Locale.current) -> String {
        let formatter = Date.formatter(dateStyle, timeStyle: timeStyle, doesRelativeDateFormatting: doesRelativeDateFormatting, timeZone: timeZone, locale: locale)
        return formatter.string(from: self)
    }
    
    func weekdayToString() -> String {
        let formatter = Date.formatter()
        return formatter.weekdaySymbols[self.weekday()-1] as String
    }
    
    func shortWeekdayToString() -> String {
        let formatter = Date.formatter()
        return formatter.shortWeekdaySymbols[self.weekday()-1] as String
    }
    
    func veryShortWeekdayToString() -> String {
        let formatter = Date.formatter()
        return formatter.veryShortWeekdaySymbols[self.weekday()-1] as String
    }
    
    func monthToString() -> String {
        let formatter = Date.formatter()
        return formatter.monthSymbols[self.month()-1] as String
    }
    
    func shortMonthToString() -> String {
        let formatter = Date.formatter()
        return formatter.shortMonthSymbols[self.month()-1] as String
    }
    
    func veryShortMonthToString() -> String {
        let formatter = Date.formatter()
        return formatter.veryShortMonthSymbols[self.month()-1] as String
    }
    
    static let sharedDateFormatters : [String: DateFormatter] = {
        let instance = [String: DateFormatter]()
        return instance
    }()
    
    fileprivate static func formatter(_ format:String = DefaultFormat, timeZone: Foundation.TimeZone = Foundation.TimeZone.autoupdatingCurrent, locale: Locale = Locale.current) -> DateFormatter {
        let hashKey = "\(format.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
        var formatters = Date.sharedDateFormatters
        if let cachedDateFormatter = formatters[hashKey] {
            return cachedDateFormatter
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = timeZone
            formatter.locale = locale
            formatters[hashKey] = formatter
            return formatter
        }
    }
    
    fileprivate static func formatter(_ dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, doesRelativeDateFormatting: Bool, timeZone: Foundation.TimeZone = Foundation.TimeZone.autoupdatingCurrent, locale: Locale = Locale.current) -> DateFormatter {
        var formatters = Date.sharedDateFormatters
        let hashKey = "\(dateStyle.hashValue)\(timeStyle.hashValue)\(doesRelativeDateFormatting.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
        if let cachedDateFormatter = formatters[hashKey] {
            return cachedDateFormatter
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = dateStyle
            formatter.timeStyle = timeStyle
            formatter.doesRelativeDateFormatting = doesRelativeDateFormatting
            formatter.timeZone = timeZone
            formatter.locale = locale
            formatters[hashKey] = formatter
            return formatter
        }
    }
    
    fileprivate var calendar: Calendar {
        return Calendar.current
    }
    
    static func date(_ year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date {
        let now = Date()
        return now.change(year, month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
    func change(_ year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date! {
        var c = self.components()
        c.year = year ?? self.year()
        c.month = month ?? self.month()
        c.day = day ?? self.day()
        c.hour = hour ?? self.hour()
        c.minute = minute ?? self.minute()
        return calendar.date(from: c)
    }
    
}

// MARK: - NSMutableString

extension NSMutableString {
    
    func separateStringWithCaps(){
        var index = 1
        while(index < self.length){
            if CharacterSet.uppercaseLetters.contains(UnicodeScalar(self.character(at: index))!){
                self.insert(" ", at: index)
                index += 1
            }
            index += 1
        }
    }
    
}

extension Dictionary {
    /// EZSE: Returns a random element inside Dictionary
    public func random() -> Value {
        let index: Int = Int(arc4random_uniform(UInt32(self.count)))
        return Array(self.values)[index]
    }
    
    /// EZSE: Union of self and the input dictionaries.
    public func union(_ dictionaries: Dictionary...) -> Dictionary {
        var result = self
        dictionaries.forEach { (dictionary) -> Void in
            dictionary.forEach { (key, value) -> Void in
                _ = result.updateValue(value, forKey: key)
            }
        }
        return result
    }
    
    /// EZSE: Intersection of self and the input dictionaries.
    /// Two dictionaries are considered equal if they contain the same [key: value] copules.
    public func intersection<K, V>(_ dictionaries: [K: V]...) -> [K: V] where K: Equatable, V: Equatable {
        //  Casts self from [Key: Value] to [K: V]
        let filtered = mapFilter { (item, value) -> (K, V)? in
            if let item = item as? K, let value = value as? V {
                return (item, value)
            }
            return nil
        }
        
        //  Intersection
        return filtered.filter { (key: K, value: V) -> Bool in
            //  check for [key: value] in all the dictionaries
            dictionaries.testAll { $0.has(key) && $0[key] == value }
        }
    }
    
    /// EZSE: Checks if a key exists in the dictionary.
    public func has(_ key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    
    /// EZSE: Creates an Array with values generated by running
    /// each [key: value] of self through the mapFunction.
    public func toArray<V>(_ map: (Key, Value) -> V) -> [V] {
        var mapped: [V] = []
        forEach {
            mapped.append(map($0, $1))
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with the same keys as self and values generated by running
    /// each [key: value] of self through the mapFunction.
    public func mapValues<V>(_ map: (Key, Value) -> V) -> [Key: V] {
        var mapped: [Key: V] = [:]
        forEach {
            mapped[$0] = map($0, $1)
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with the same keys as self and values generated by running
    /// each [key: value] of self through the mapFunction discarding nil return values.
    public func mapFilterValues<V>(_ map: (Key, Value) -> V?) -> [Key: V] {
        var mapped: [Key: V] = [:]
        forEach {
            if let value = map($0, $1) {
                mapped[$0] = value
            }
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with keys and values generated by running
    /// each [key: value] of self through the mapFunction discarding nil return values.
    public func mapFilter<K, V>(_ map: (Key, Value) -> (K, V)?) -> [K: V] {
        var mapped: [K: V] = [:]
        forEach {
            if let value = map($0, $1) {
                mapped[value.0] = value.1
            }
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with keys and values generated by running
    /// each [key: value] of self through the mapFunction.
    public func map<K, V>(_ map: (Key, Value) -> (K, V)) -> [K: V] {
        var mapped: [K: V] = [:]
        forEach {
            let (_key, _value) = map($0, $1)
            mapped[_key] = _value
        }
        return mapped
    }
    
    /// EZSE: Constructs a dictionary containing every [key: value] pair from self
    /// for which testFunction evaluates to true.
    public func filter(_ test: (Key, Value) -> Bool) -> Dictionary {
        var result = Dictionary()
        for (key, value) in self {
            if test(key, value) {
                result[key] = value
            }
        }
        return result
    }
    
    /// EZSE: Checks if test evaluates true for all the elements in self.
    public func testAll(_ test: (Key, Value) -> (Bool)) -> Bool {
        for (key, value) in self {
            if !test(key, value) {
                return false
            }
        }
        return true
    }
}

extension Dictionary where Value: Equatable {
    /// EZSE: Difference of self and the input dictionaries.
    /// Two dictionaries are considered equal if they contain the same [key: value] pairs.
    public func difference(_ dictionaries: [Key: Value]...) -> [Key: Value] {
        var result = self
        for dictionary in dictionaries {
            for (key, value) in dictionary {
                if result.has(key) && result[key] == value {
                    result.removeValue(forKey: key)
                }
            }
        }
        return result
    }
}

/// EZSE: Combines the first dictionary with the second and returns single dictionary
public func += <KeyType, ValueType> (left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

/// EZSE: Difference operator
public func - <K, V: Equatable> (first: [K: V], second: [K: V]) -> [K: V] {
    return first.difference(second)
}


/// EZSE: Intersection operator
public func & <K, V: Equatable> (first: [K: V], second: [K: V]) -> [K: V] {
    return first.intersection(second)
}

/// EZSE: Union operator
public func | <K: Hashable, V> (first: [K: V], second: [K: V]) -> [K: V] {
    return first.union(second)
}

// MARK: - NSMutableAttributedString

extension NSMutableAttributedString {
    
    func applyAttributesBySearching(_ subString:String,attributes:NSDictionary) {
        do{
            let expression = try NSRegularExpression(pattern: subString,options:[.caseInsensitive])
            expression.enumerateMatches(in: self.string, options: [.reportProgress], range:  NSMakeRange(0, self.string.length), using: { (result, flags, stop) in
                if isNotNull(result){
                    let range = result!.rangeAt(0)
                    self.addAttributes(attributes as! [String : Any], range:range)
                }
            })
        }catch{}
    }
    
    func replaceOccuranceOf(_ subString:String,withImage:UIImage) {
        do{
            let expression = try NSRegularExpression(pattern: subString,options:[.caseInsensitive])
            expression.enumerateMatches(in: self.string, options: [.reportProgress], range:  NSMakeRange(0, self.string.length), using: { (result, flags, stop) in
                if isNotNull(result){
                    let range = result!.rangeAt(0)
                    let attachment = NSTextAttachment()
                    attachment.image = withImage
                    self.replaceCharacters(in: range, with: NSAttributedString(attachment: attachment))
                }
            })
        }catch{}
    }
    
    func replaceOccuranceOf(_ subString:String,withString:String,attributes:NSDictionary) {
        do{
            let stringToReplaceWith = NSAttributedString(string:withString,attributes: attributes as! [String : Any])
            let expression = try NSRegularExpression(pattern: subString,options:[.caseInsensitive])
            expression.enumerateMatches(in: self.string, options: [.reportProgress], range:  NSMakeRange(0, self.string.length), using: { (result, flags, stop) in
                if isNotNull(result){
                    let range = result!.rangeAt(0)
                    self.replaceCharacters(in: range, with:stringToReplaceWith)
                }
            })
        }catch{}
    }
    
}

// MARK: - UIView

extension UIView {
    
    func performAppearAnimationType1(){
        let option = UIViewAnimationOptions.curveLinear
        self.layer.opacity = 0.01
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4, delay: 0.4, options: option, animations: {
            self.layer.opacity = 0.8
        }) { (completed) in
        }
        UIView.animate(withDuration: 0.4 - 2*0.08, delay: 0.4, options: option, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (completed) in
            UIView.animate(withDuration: 0.08, delay: 0, options: option, animations: {
                self.layer.opacity = 0.9
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }) { (completed) in
                UIView.animate(withDuration: 0.08, delay: 0, options: option, animations: {
                    self.layer.opacity = 1.0
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }) { (completed) in
                }
            }
        }
    }
    
    func performAppearAnimationType2(_ delay:Double){
        self.layoutIfNeeded()
        self.layer.removeAllAnimations()
        let delayDuration = 0.4 + delay
        let option = UIViewAnimationOptions.curveLinear
        self.layer.opacity = 0.01
        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.4, delay: 0.4 + delay, options: option, animations: {
            self.layer.opacity = 0.8
        }) { (completed) in
        }
        UIView.animate(withDuration: 0.4 - 2*0.08, delay: delayDuration, options: option, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (completed) in
            UIView.animate(withDuration: 0.08, delay: 0, options: option, animations: {
                self.layer.opacity = 0.9
                self.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            }) { (completed) in
                UIView.animate(withDuration: 0.08, delay: 0, options: option, animations: {
                    self.layer.opacity = 1.0
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }) { (completed) in
                }
            }
        }
    }
    
    func performAppearAnimationType3(){
        let option = UIViewAnimationOptions.curveLinear
        self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        UIView.animate(withDuration: 0.4 - 2*0.08, delay: 0.4, options: option, animations: {
            self.transform = CGAffineTransform(scaleX: 0.99, y: 0.99)
        }) { (completed) in
            UIView.animate(withDuration: 0.08, delay: 0, options: option, animations: {
                self.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
            }) { (completed) in
                UIView.animate(withDuration: 0.08, delay: 0, options: option, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }) { (completed) in
                }
            }
        }
    }
    
    func performAppearAnimationType5(_ delay:Double){
        self.layoutIfNeeded()
        _ = 0.4 + delay
        let option = UIViewAnimationOptions.curveLinear
        self.layer.opacity = 0.01
        UIView.animate(withDuration: 0.4, delay: 0.4 + delay, options: option, animations: {
            self.layer.opacity = 1.0
        }) { (completed) in
        }
    }
    
    func showActivityIndicatorAtPoint(_ point:CGPoint) {
        hideActivityIndicator()
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = point
        activityIndicatorView.tag = 102345
        activityIndicatorView.transform = CGAffineTransform(scaleX: 0.6,y: 0.6)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = true;
        DispatchQueue.main.async { () -> Void in
            activityIndicatorView.center = point
            activityIndicatorView.isHidden = false;
        }
    }
    
    func showActivityIndicatorType(_ point:CGPoint,style:UIActivityIndicatorViewStyle) {
        hideActivityIndicator()
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: style)
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = point
        activityIndicatorView.tag = 102345
        activityIndicatorView.transform = CGAffineTransform(scaleX: 0.6,y: 0.6)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = true;
        DispatchQueue.main.async { () -> Void in
            activityIndicatorView.center = point
            activityIndicatorView.isHidden = false;
        }
    }
    
    func showActivityIndicator() {
        hideActivityIndicator()
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = self.center
        activityIndicatorView.center = self.center
        activityIndicatorView.tag = 102345
        activityIndicatorView.transform = CGAffineTransform(scaleX: 0.6,y: 0.6)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = true;
        DispatchQueue.main.async { () -> Void in
            activityIndicatorView.center = self.center
            activityIndicatorView.isHidden = false;
        }
    }
    
    func showActivityIndicatorWhite() {
        hideActivityIndicator()
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = self.center
        activityIndicatorView.tag = 102345
        activityIndicatorView.transform = CGAffineTransform(scaleX: 0.6,y: 0.6)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = true;
        DispatchQueue.main.async { () -> Void in
            activityIndicatorView.center = self.center
            activityIndicatorView.isHidden = false;
        }
    }
    
    func hideActivityIndicator() {
        self .viewWithTag(102345)?.removeFromSuperview()
    }
    
    func makeMeRound(){
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.bounds.size.width/2
        self.layer.borderWidth = 0
        self.layer.masksToBounds = true
    }
    
    func makeMeRoundWith(borderColor:UIColor,width:CGFloat){
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.bounds.size.width/2
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = true
    }
    
}

// MARK: - NSDictionary

extension NSDictionary {
    
    func removeNullValues()->NSMutableDictionary {
        do{
            let mutableCopySelf = self.mutableCopy() as! NSMutableDictionary
            let nullSet = mutableCopySelf.keysOfEntries(options: [.concurrent]) { (key, object, stop) -> Bool in
                return isNull(object)
            }
            try mutableCopySelf.removeObjects(forKeys: Array(nullSet))
            return mutableCopySelf
        }catch{
            logMessage("removeNullValues : \(error)")
            return self.mutableCopy() as! NSMutableDictionary
        }
    }
    
}

// MARK: - CGRect

extension CGRect {
    
    public init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init(x: x, y: y, width: w, height: h)
    }
    
    public var x: CGFloat {
        get {
            return self.origin.x
        } set(value) {
            self.origin.x = value
        }
    }
    
    public var y: CGFloat {
        get {
            return self.origin.y
        } set(value) {
            self.origin.y = value
        }
    }
    
    public var w: CGFloat {
        get {
            return self.size.width
        } set(value) {
            self.size.width = value
        }
    }
    
    public var h: CGFloat {
        get {
            return self.size.height
        } set(value) {
            self.size.height = value
        }
    }
    
    var width: CGFloat {
        get {
            return self.size.width
        }
        set {
            self = CGRect(x: self.x, y: self.width, width: newValue, height: self.height)
        }
    }
    
    var height: CGFloat {
        get {
            return self.size.height
        }
        set {
            self = CGRect(x: self.x, y: self.minY, width: self.width, height: newValue)
        }
    }
    
    public init(_ origin: CGPoint, _ size: CGSize) {
        self.origin = origin
        self.size = size
    }
    
    public init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.origin = CGPoint(x: x, y: y)
        self.size = CGSize(width: width, height: height)
    }
    
    public var centerX: CGFloat {
        get {return x + width * 0.5}
        set {x = newValue - width * 0.5}
    }
    
    public var centerY: CGFloat {
        get {return y + height * 0.5}
        set {y = newValue - height * 0.5}
    }
    
    public var left: CGFloat {
        get {return origin.x}
        set {origin.x = newValue}
    }
    
    public var right: CGFloat {
        get {return x + width}
        set {x = newValue - width}
    }
    
    #if os(iOS)
    
    public var top: CGFloat {
        get {return y}
        set {y = newValue}
    }
    
    public var bottom: CGFloat {
        get {return y + height}
        set {y = newValue - height}
    }
    #else
    
    public var top: CGFloat {
    get {return y + height}
    set {y = newValue - height}
    }
    
    public var bottom: CGFloat {
    get {return y}
    set {y = newValue}
    }
    #endif
    
    public var topLeft: CGPoint {
        get {return CGPoint(x: left, y: top)}
        set {left = newValue.x; top = newValue.y}
    }
    
    public var topCenter: CGPoint {
        get {return CGPoint(x: centerX, y: top)}
        set {centerX = newValue.x; top = newValue.y}
    }
    
    public var topRight: CGPoint {
        get {return CGPoint(x: right, y: top)}
        set {right = newValue.x; top = newValue.y}
    }
    
    public var centerLeft: CGPoint {
        get {return CGPoint(x: left, y: centerY)}
        set {left = newValue.x; centerY = newValue.y}
    }
    
    public var center: CGPoint {
        get {return CGPoint(x: centerX, y: centerY)}
        set {centerX = newValue.x; centerY = newValue.y}
    }
    
    public var centerRight: CGPoint {
        get {return CGPoint(x: right, y: centerY)}
        set {right = newValue.x; centerY = newValue.y}
    }
    
    public var bottomLeft: CGPoint {
        get {return CGPoint(x: left, y: bottom)}
        set {left = newValue.x; bottom = newValue.y}
    }
    
    public var bottomCenter: CGPoint {
        get {return CGPoint(x: centerX, y: bottom)}
        set {centerX = newValue.x; bottom = newValue.y}
    }
    
    public var bottomRight: CGPoint {
        get {return CGPoint(x: right, y: bottom)}
        set {right = newValue.x; bottom = newValue.y}
    }
    
    public func with(origin: CGPoint) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    public func with(x: CGFloat, y: CGFloat) -> CGRect {
        return with(origin: CGPoint(x: x, y: y))
    }
    
    public func with(x: CGFloat) -> CGRect {
        return with(x: x, y: y)
    }
    
    public func with(y: CGFloat) -> CGRect {
        return with(x: x, y: y)
    }
    
    public func with(size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    public func with(width: CGFloat, height: CGFloat) -> CGRect {
        return with(size: CGSize(width: width, height: height))
    }
    
    public func with(width: CGFloat) -> CGRect {
        return with(width: width, height: height)
    }
    
    public func with(height: CGFloat) -> CGRect {
        return with(width: width, height: height)
    }
    
    public func with(x: CGFloat, width: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }
    
    public func with(y: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }
    
    public func offsetBy(dx: CGFloat, _ dy: CGFloat) -> CGRect {
        return with(x: x + dx, y: y + dy)
    }
    
    public func offsetBy(dx: CGFloat) -> CGRect {
        return with(x: x + dx)
    }
    
    public func offsetBy(dy: CGFloat) -> CGRect {
        return with(y: y + dy)
    }
    
    public func offsetBy(by: CGSize) -> CGRect {
        return with(x: x + by.width, y: y + by.height)
    }
    
    public mutating func offsetInPlace(dx: CGFloat, _ dy: CGFloat) {
        offsetInPlace(dx: dx, dy)
    }
    
    public mutating func offsetInPlace(dx: CGFloat = 0) {
        x += dx
    }
    
    public mutating func offsetInPlace(dy: CGFloat = 0) {
        y += dy
    }
    
    public mutating func offsetInPlace(by: CGSize) {
        offsetInPlace(dx: by.width, by.height)
    }
    
    public func center(size: CGSize) -> CGRect {
        let dx = width - size.width
        let dy = height - size.height
        return CGRect(x: x + dx * 0.5, y: y + dy * 0.5, width: size.width, height: size.height)
    }
    
    public func center(size: CGSize, alignTo edge: CGRectEdge) -> CGRect {
        return CGRect(origin: alignedOrigin(size: size, edge: edge), size: size)
    }
    
    private func alignedOrigin(size: CGSize, edge: CGRectEdge) -> CGPoint {
        let dx = width - size.width
        let dy = height - size.height
        switch edge {
        case .minXEdge:
            return CGPoint(x: x, y: y + dy * 0.5)
        case .minYEdge:
            return CGPoint(x: x + dx * 0.5, y: y)
        case .maxXEdge:
            return CGPoint(x: x + dx, y: y + dy * 0.5)
        case .maxYEdge:
            return CGPoint(x: x + dx * 0.5, y: y + dy)
        }
    }
}

// MARK: - UserDefaults

public extension UserDefaults {
    
    class Proxy {
        fileprivate let defaults: UserDefaults
        fileprivate let key: String
        
        fileprivate init(_ defaults: UserDefaults, _ key: String) {
            self.defaults = defaults
            self.key = key
        }
        
        // MARK: Getters
        
        open var object: NSObject? {
            return defaults.object(forKey: key) as? NSObject
        }
        
        open var string: String? {
            return defaults.string(forKey: key)
        }
        
        open var array: NSArray? {
            return defaults.array(forKey: key) as NSArray?
        }
        
        open var dictionary: NSDictionary? {
            return defaults.dictionary(forKey: key) as NSDictionary?
        }
        
        open var data: Data? {
            return defaults.data(forKey: key)
        }
        
        open var date: Date? {
            return object as? Date
        }
        
        open var number: NSNumber? {
            return object as? NSNumber
        }
        
        open var int: Int? {
            return number?.intValue
        }
        
        open var double: Double? {
            return number?.doubleValue
        }
        
        open var bool: Bool? {
            return number?.boolValue
        }
    }
    
    public subscript(key: String) -> Proxy {
        return Proxy(self, key)
    }
    
    public subscript(key: String) -> Any? {
        get {
            return self.object(forKey: key)
        }
        set {
            if let v = newValue as? Int {
                set(v, forKey: key)
            } else if let v = newValue as? Double {
                set(v, forKey: key)
            } else if let v = newValue as? Bool {
                set(v, forKey: key)
            } else if let v = newValue as? NSObject {
                set(v, forKey: key)
            } else if newValue == nil {
                removeObject(forKey: key)
            } else {
                assertionFailure("Invalid value type")
            }
        }
    }
    
    public func hasKey(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }
    
    public func remove(_ key: String) {
        removeObject(forKey: key)
    }
}

infix operator ?= {
associativity right
precedence 90
}

public func ?= (proxy: UserDefaults.Proxy, expr: @autoclosure () -> Any) {
    if !proxy.defaults.hasKey(proxy.key) {
        proxy.defaults[proxy.key] = expr()
    }
}

public func += (proxy: UserDefaults.Proxy, b: Int) {
    let a = proxy.defaults[proxy.key].int ?? 0
    proxy.defaults[proxy.key] = a + b
}

public func += (proxy: UserDefaults.Proxy, b: Double) {
    let a = proxy.defaults[proxy.key].double ?? 0
    proxy.defaults[proxy.key] = a + b
}

public postfix func ++ (proxy: UserDefaults.Proxy) {
    proxy += 1
}

public let Defaults = UserDefaults.standard


// MARK: - UIApplication

public extension UIApplication {
    
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            if let top = moreNavigationController.topViewController , top.view.window != nil {
                return topViewController(top)
            } else if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
    
}

// MARK: - Int

extension Int {
    /// EZSE: Checks if the integer is even.
    public var isEven: Bool { return (self % 2 == 0) }
    
    /// EZSE: Checks if the integer is odd.
    public var isOdd: Bool { return (self % 2 != 0) }
    
    /// EZSE: Checks if the integer is positive.
    public var isPositive: Bool { return (self > 0) }
    
    /// EZSE: Checks if the integer is negative.
    public var isNegative: Bool { return (self < 0) }
    
    /// EZSE: Converts integer value to Double.
    public var toDouble: Double { return Double(self) }
    
    /// EZSE: Converts integer value to Float.
    public var toFloat: Float { return Float(self) }
    
    /// EZSE: Converts integer value to CGFloat.
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
    /// EZSE: Converts integer value to String.
    public var toString: String { return String(self) }
    
    /// EZSE: Converts integer value to UInt.
    public var toUInt: UInt { return UInt(abs(self)) }
    
    /// EZSE: Converts integer value to a 0..<Int range. Useful in for loops.
    public var range: CountableRange<Int> { return 0..<self }
    
    /// EZSE: Returns number of digits in the integer.
    public var digits: Int {
        if self == 0 {
            return 1
        } else if Int(fabs(Double(self))) <= LONG_MAX {
            return Int(log10(fabs(Double(self)))) + 1
        } else {
            return -1; //out of bound
        }
    }
    
}

// MARK: - UInt

extension UInt {
    /// EZSE: Convert UInt to Int
    public var toInt: Int { return Int(self) }
}

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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}


extension Array {
    /// EZSE: Returns a random element from the array.
    public func random() -> Element? {
        guard self.count > 0 else {
            return nil
        }
        
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
    /// EZSE: Checks if array contains at least 1 instance of the given object type
    public func containsInstanceOf<T>(_ object: T) -> Bool {
        for item in self {
            if type(of: item) == type(of: object) {
                return true
            }
        }
        return false
    }
    
    /// EZSE: Checks if test returns true for all the elements in self
    public func testAll(_ test: (Element) -> Bool) -> Bool {
        for item in self {
            if !test(item) {
                return false
            }
        }
        return true
    }
    
    /// EZSE: Checks if all elements in the array are true of false
    public func testIfAllIs(_ condition: Bool) -> Bool {
        for item in self {
            guard let item = item as? Bool else { return false }
            
            if item != condition {
                return false
            }
        }
        return true
    }
    
    /// EZSE: Gets the object at the specified index, if it exists.
    public func get(_ index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
    
    /// EZSE: Reverse the given index. i.g.: reverseIndex(2) would be 2 to the last
    public func reverseIndex(_ index: Int) -> Int {
        return Swift.max(self.count - 1 - index, 0)
    }
    
    /// EZSE: Returns an array with the given number as the max number of elements.
    public func takeMax(_ n: Int) -> Array {
        return Array(self[0..<Swift.max(0, Swift.min(n, count))])
    }
    
    /// EZSE: Iterates on each element of the array.
    public func each(_ call: (Element) -> ()) {
        for item in self {
            call(item)
        }
    }
    
    /// EZSE: Iterates on each element of the array with its index.
    public func each(_ call: (Int, Element) -> ()) {
        for (index, item) in self.enumerated() {
            call(index, item)
        }
    }
    
    /// EZSE: Creates an array with values generated by running each value of self
    /// through the mapFunction and discarding nil return values.
    public func mapFilter<V>(mapFunction map: (Element) -> (V)?) -> [V] {
        var mapped = [V]()
        each { (value: Element) -> Void in
            if let mappedValue = map(value) {
                mapped.append(mappedValue)
            }
        }
        return mapped
    }
    
    /// EZSE: Prepends an object to the array.
    public mutating func insertAsFirst(_ newElement: Element) {
        insert(newElement, at: 0)
    }
    
    /// EZSE: Shuffles the array in-place using the Fisher-Yates-Durstenfeld algorithm.
    public mutating func shuffle() {
        var j: Int
        
        for i in 0..<(self.count-2) {
            j = Int(arc4random_uniform(UInt32(self.count - i)))
            if i != i+j { swap(&self[i], &self[i+j]) }
        }
    }
}

extension Array where Element: Equatable {
    
    /// EZSE: Returns the indexes of the object
    public func indexesOf(_ object: Element) -> [Int] {
        var indexes = [Int]()
        for index in 0..<self.count {
            if self[index] == object {
                indexes.append(index)
            }
        }
        return indexes
    }
    
    /// EZSE: Returns the last index of the object
    public func lastIndexOf(_ object: Element) -> Int? {
        return indexesOf(object).last
    }
    
    /// EZSE: Checks if self contains a list of items.
    public func contains(_ items: Element...) -> Bool {
        return items.testAll { self.index(of: $0) >= 0 }
    }
    
    /// EZSE: Difference of self and the input arrays.
    public func difference(_ values: [Element]...) -> [Element] {
        var result = [Element]()
        elements: for element in self {
            for value in values {
                //  if a value is in both self and one of the values arrays
                //  jump to the next iteration of the outer loop
                if value.contains(element) {
                    continue elements
                }
            }
            //  element it's only in self
            result.append(element)
        }
        return result
    }
    
    /// EZSE: Intersection of self and the input arrays.
    public func intersection(_ values: [Element]...) -> Array {
        var result = self
        var intersection = Array()
        
        for (i, value) in values.enumerated() {
            //  the intersection is computed by intersecting a couple per loop:
            //  self n values[0], (self n values[0]) n values[1], ...
            if i > 0 {
                result = intersection
                intersection = Array()
            }
            
            //  find common elements and save them in first set
            //  to intersect in the next loop
            value.each { (item: Element) -> Void in
                if result.contains(item) {
                    intersection.append(item)
                }
            }
        }
        return intersection
    }
    
    /// EZSE: Union of self and the input arrays.
    public func union(_ values: [Element]...) -> Array {
        var result = self
        for array in values {
            for value in array {
                if !result.contains(value) {
                    result.append(value)
                }
            }
        }
        return result
    }
    
    /// EZSE: Removes the first given object
    public mutating func removeObject(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    /// EZSE: Removes all occurrences of the given object
    public mutating func removeObjects(_ object: Element) {
        for i in self.indexesOf(object).reversed() {
            self.remove(at: i)
        }
    }
    
    /// EZSE: Checks if the main array contains the parameter array
    public func containsArray(_ lookFor: [Element]) -> Bool {
        for item in lookFor {
            if self.contains(item) == false {
                return false
            }
        }
        return true
    }
}

public func ==<T: Equatable>(lhs: [T]?, rhs: [T]?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)):
        return lhs == rhs
    case (.none, .none):
        return true
    default:
        return false
    }
}

extension UIWindow {
    /// EZSE: Creates and shows UIWindow. The size will show iPhone4 size until you add launch images with proper sizes. TODO: Add to readme
    public convenience init(viewController: UIViewController, backgroundColor: UIColor) {
        self.init(frame: UIScreen.main.bounds)
        self.rootViewController = viewController
        self.backgroundColor = backgroundColor
        self.makeKeyAndVisible()
    }
}

// MARK: Custom UIView Initilizers
extension UIView {
    /// EZSwiftExtensions
    public convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
    }
    
    /// EZSwiftExtensions, puts padding around the view
    public convenience init(superView: UIView, padding: CGFloat) {
        self.init(frame: CGRect(x: superView.x + padding, y: superView.y + padding, width: superView.w - padding*2, height: superView.h - padding*2))
    }
    
    /// EZSwiftExtensions - Copies size of superview
    public convenience init(superView: UIView) {
        self.init(frame: CGRect(origin: CGPoint.zero, size: superView.size))
    }
}

// MARK: Frame Extensions
extension UIView {
    //TODO: Multipe addsubview
    //TODO: Add pics to readme
    /// EZSwiftExtensions, resizes this view so it fits the largest subview
    public func resizeToFitSubviews() {
        var width: CGFloat = 0
        var height: CGFloat = 0
        for someView in self.subviews {
            let aView = someView
            let newWidth = aView.x + aView.w
            let newHeight = aView.y + aView.h
            width = max(width, newWidth)
            height = max(height, newHeight)
        }
        frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    /// EZSwiftExtensions, resizes this view so it fits the largest subview
    public func resizeToFitSubviews(_ tagsToIgnore: [Int]) {
        var width: CGFloat = 0
        var height: CGFloat = 0
        for someView in self.subviews {
            let aView = someView
            if !tagsToIgnore.contains(someView.tag) {
                let newWidth = aView.x + aView.w
                let newHeight = aView.y + aView.h
                width = max(width, newWidth)
                height = max(height, newHeight)
            }
        }
        frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    /// EZSwiftExtensions
    public func resizeToFitWidth() {
        let currentHeight = self.h
        self.sizeToFit()
        self.h = currentHeight
    }
    
    /// EZSwiftExtensions
    public func resizeToFitHeight() {
        let currentWidth = self.w
        self.sizeToFit()
        self.w = currentWidth
    }
    
    /// EZSwiftExtensions
    public var x: CGFloat {
        get {
            return self.frame.origin.x
        } set(value) {
            self.frame = CGRect(x: value, y: self.y, width: self.w, height: self.h)
        }
    }
    
    /// EZSwiftExtensions
    public var y: CGFloat {
        get {
            return self.frame.origin.y
        } set(value) {
            self.frame = CGRect(x: self.x, y: value, width: self.w, height: self.h)
        }
    }
    
    /// EZSwiftExtensions
    public var w: CGFloat {
        get {
            return self.frame.size.width
        } set(value) {
            self.frame = CGRect(x: self.x, y: self.y, width: value, height: self.h)
        }
    }
    
    /// EZSwiftExtensions
    public var h: CGFloat {
        get {
            return self.frame.size.height
        } set(value) {
            self.frame = CGRect(x: self.x, y: self.y, width: self.w, height: value)
        }
    }
    
    /// EZSwiftExtensions
    public var left: CGFloat {
        get {
            return self.x
        } set(value) {
            self.x = value
        }
    }
    
    /// EZSwiftExtensions
    public var right: CGFloat {
        get {
            return self.x + self.w
        } set(value) {
            self.x = value - self.w
        }
    }
    
    /// EZSwiftExtensions
    public var top: CGFloat {
        get {
            return self.y
        } set(value) {
            self.y = value
        }
    }
    
    /// EZSwiftExtensions
    public var bottom: CGFloat {
        get {
            return self.y + self.h
        } set(value) {
            self.y = value - self.h
        }
    }
    
    /// EZSwiftExtensions
    public var origin: CGPoint {
        get {
            return self.frame.origin
        } set(value) {
            self.frame = CGRect(origin: value, size: self.frame.size)
        }
    }
    
    /// EZSwiftExtensions
    public var centerX: CGFloat {
        get {
            return self.center.x
        } set(value) {
            self.center.x = value
        }
    }
    
    /// EZSwiftExtensions
    public var centerY: CGFloat {
        get {
            return self.center.y
        } set(value) {
            self.center.y = value
        }
    }
    
    /// EZSwiftExtensions
    public var size: CGSize {
        get {
            return self.frame.size
        } set(value) {
            self.frame = CGRect(origin: self.frame.origin, size: value)
        }
    }
    
    /// EZSwiftExtensions
    public func leftOffset(_ offset: CGFloat) -> CGFloat {
        return self.left - offset
    }
    
    /// EZSwiftExtensions
    public func rightOffset(_ offset: CGFloat) -> CGFloat {
        return self.right + offset
    }
    
    /// EZSwiftExtensions
    public func topOffset(_ offset: CGFloat) -> CGFloat {
        return self.top - offset
    }
    
    /// EZSwiftExtensions
    public func bottomOffset(_ offset: CGFloat) -> CGFloat {
        return self.bottom + offset
    }
    
    //TODO: Add to readme
    /// EZSwiftExtensions
    public func alignRight(_ offset: CGFloat) -> CGFloat {
        return self.w - offset
    }
    
    /// EZSwiftExtensions
    public func reorderSubViews(_ reorder: Bool = false, tagsToIgnore: [Int] = []) -> CGFloat {
        var currentHeight: CGFloat = 0
        for someView in subviews {
            if !tagsToIgnore.contains(someView.tag) && !(someView).isHidden {
                if reorder {
                    let aView = someView
                    aView.frame = CGRect(x: aView.frame.origin.x, y: currentHeight, width: aView.frame.width, height: aView.frame.height)
                }
                currentHeight += someView.frame.height
            }
        }
        return currentHeight
    }
    
    public func removeSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    /// EZSE: Centers view in superview horizontally
    public func centerXInSuperView() {
        guard let parentView = superview else {
            assertionFailure("EZSwiftExtensions Error: The view \(self) doesn't have a superview")
            return
        }
        
        self.x = parentView.w/2 - self.w/2
    }
    
    /// EZSE: Centers view in superview vertically
    public func centerYInSuperView() {
        guard let parentView = superview else {
            assertionFailure("EZSwiftExtensions Error: The view \(self) doesn't have a superview")
            return
        }
        
        self.y = parentView.h/2 - self.h/2
    }
    
    /// EZSE: Centers view in superview horizontally & vertically
    public func centerInSuperView() {
        self.centerXInSuperView()
        self.centerYInSuperView()
    }
}

// MARK: Layer Extensions
extension UIView {
    
    //TODO: add this to readme
    /// EZSwiftExtensions
    public func addShadow(_ offset: CGSize, radius: CGFloat, color: UIColor, opacity: Float, cornerRadius: CGFloat? = nil) {
        self.layoutIfNeeded()
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = color.cgColor
        if let r = cornerRadius {
            self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: r).cgPath
        }
    }
    
    /// EZSwiftExtensions
    public func addBorder(_ width: CGFloat, color: UIColor) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        layer.masksToBounds = true
    }
    
    /// EZSwiftExtensions
    public func addBorderTop(_ size: CGFloat, color: UIColor) {
        addBorderUtility(0, y: 0, width: frame.width, height: size, color: color)
    }
    
    //TODO: add to readme
    /// EZSwiftExtensions
    public func addBorderTopWithPadding(_ size: CGFloat, color: UIColor, padding: CGFloat) {
        addBorderUtility(padding, y: 0, width: frame.width - padding*2, height: size, color: color)
    }
    
    /// EZSwiftExtensions
    public func addBorderBottom(_ size: CGFloat, color: UIColor) {
        addBorderUtility(0, y: frame.height - size, width: frame.width, height: size, color: color)
    }
    
    /// EZSwiftExtensions
    public func addBorderLeft(_ size: CGFloat, color: UIColor) {
        addBorderUtility(0, y: 0, width: size, height: frame.height, color: color)
    }
    
    /// EZSwiftExtensions
    public func addBorderRight(_ size: CGFloat, color: UIColor) {
        addBorderUtility(frame.width - size, y: 0, width: size, height: frame.height, color: color)
    }
    
    /// EZSwiftExtensions
    fileprivate func addBorderUtility(_ x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.addSublayer(border)
    }
    //TODO: add this to readme
    /// EZSwiftExtensions
    public func drawCircle(_ fillColor: UIColor, strokeColor: UIColor, strokeWidth: CGFloat) {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.w, height: self.w), cornerRadius: self.w/2)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = strokeWidth
        self.layer.addSublayer(shapeLayer)
    }
    //TODO: add this to readme
    /// EZSwiftExtensions
    public func drawStroke(_ width: CGFloat, color: UIColor) {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.w, height: self.w), cornerRadius: self.w/2)
        let shapeLayer = CAShapeLayer ()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        self.layer.addSublayer(shapeLayer)
    }
}

private let UIViewAnimationDuration: TimeInterval = 1
private let UIViewAnimationSpringDamping: CGFloat = 0.5
private let UIViewAnimationSpringVelocity: CGFloat = 0.5

//TODO: add this to readme
// MARK: Animation Extensions
extension UIView {
    /// EZSwiftExtensions
    public func spring(_ animations: @escaping (() -> Void), completion: ((Bool) -> Void)? = nil) {
        spring(UIViewAnimationDuration, animations: animations, completion: completion)
    }
    
    /// EZSwiftExtensions
    public func spring(_ duration: TimeInterval, animations: @escaping (() -> Void), completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: UIViewAnimationDuration,
            delay: 0,
            usingSpringWithDamping: UIViewAnimationSpringDamping,
            initialSpringVelocity: UIViewAnimationSpringVelocity,
            options: UIViewAnimationOptions.allowAnimatedContent,
            animations: animations,
            completion: completion
       )
    }
    
    /// EZSwiftExtensions
    public func animate(_ duration: TimeInterval, animations: @escaping (() -> Void), completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: animations, completion: completion)
    }
    
    /// EZSwiftExtensions
    public func animate(_ animations: @escaping (() -> Void), completion: ((Bool) -> Void)? = nil) {
        animate(UIViewAnimationDuration, animations: animations, completion: completion)
    }
    
}

//TODO: add this to readme
// MARK: Render Extensions
extension UIView {
    /// EZSwiftExtensions
    public func toImage () -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

//TODO: add to readme
extension UIView {
    /// EZSwiftExtensions [UIRectCorner.TopLeft, UIRectCorner.TopRight]
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    /// EZSwiftExtensions
    public func roundView() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2
    }
}

extension UIView {
    ///EZSE: Shakes the view for as many number of times as given in the argument.
    public func shakeViewForTimes(_ times: Int) {
        let anim = CAKeyframeAnimation(keyPath: "transform")
        anim.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(-5, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation( 5, 0, 0))
        ]
        anim.autoreverses = true
        anim.repeatCount = Float(times)
        anim.duration = 7/100
        
        self.layer.add(anim, forKey: nil)
    }
}

extension UIView {
    ///EZSE: Loops until it finds the top root view. //TODO: Add to readme
    func rootView() -> UIView {
        guard let parentView = superview else {
            return self
        }
        return parentView.rootView()
    }
}

extension UILabel {
    
    /// EZSwiftExtensions
    public func getEstimatedSize(_ width: CGFloat = CGFloat.greatestFiniteMagnitude, height: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        return sizeThatFits(CGSize(width: width, height: height))
    }
    
    /// EZSwiftExtensions
    public func getEstimatedHeight() -> CGFloat {
        return sizeThatFits(CGSize(width: w, height: CGFloat.greatestFiniteMagnitude)).height
    }
    
    /// EZSwiftExtensions
    public func getEstimatedWidth() -> CGFloat {
        return sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: h)).width
    }
    
    /// EZSwiftExtensions
    public func fitHeight() {
        self.h = getEstimatedHeight()
    }
    
    /// EZSwiftExtensions
    public func fitWidth() {
        self.w = getEstimatedWidth()
    }
    
    /// EZSwiftExtensions
    public func fitSize() {
        self.fitWidth()
        self.fitHeight()
        sizeToFit()
    }
    
    /// EZSwiftExtensions
    public func setText(_ text: String?, animated: Bool, duration: TimeInterval?) {
        if animated {
            UIView.transition(with: self, duration: duration ?? 0.3, options: .transitionCrossDissolve, animations: { () -> Void in
                self.text = text
            }, completion: nil)
        } else {
            self.text = text
        }
        
    }
}

// MARK: - LocalNotificationHelper

class LocalNotificationHelper: NSObject {
    
    let LOCAL_NOTIFICATION_CATEGORY : String = "LocalNotificationCategory"
    
    class func sharedInstance() -> LocalNotificationHelper {
        struct Singleton {
            static var sharedInstance = LocalNotificationHelper()
        }
        return Singleton.sharedInstance
    }
    
    func scheduleNotification(title: String, message: String, seconds: Double, userInfo: NSDictionary?) {
        let date = NSDate(timeIntervalSinceNow: TimeInterval(seconds))
        let notification = notificationWithTitle(title: title, message: message, date: date, userInfo: userInfo, soundName: nil, hasAction: true)
        notification.category = LOCAL_NOTIFICATION_CATEGORY
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func scheduleNotification(title: String, message: String, date: NSDate, userInfo: NSDictionary?){
        let notification = notificationWithTitle(title: title, message: message, date: date, userInfo: userInfo, soundName: nil, hasAction: true)
        notification.category = LOCAL_NOTIFICATION_CATEGORY
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func scheduleNotification(title: String, message: String, seconds: Double, soundName: String, userInfo: NSDictionary?){
        let date = NSDate(timeIntervalSinceNow: TimeInterval(seconds))
        let notification = notificationWithTitle(title: title, message: message, date: date, userInfo: userInfo, soundName: soundName, hasAction: true)
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func scheduleNotification(title: String, message: String, date: NSDate, soundName: String, userInfo: NSDictionary?){
        let notification = notificationWithTitle(title: title, message: message, date: date, userInfo: userInfo, soundName: soundName, hasAction: true)
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func presentNotification(title: String, message: String, soundName: String, userInfo: NSDictionary?) {
        let notification = notificationWithTitle(title: title, message: message, date: nil, userInfo: userInfo, soundName: nil, hasAction: true)
        UIApplication.shared.presentLocalNotificationNow(notification)
    }
    
    func notificationWithTitle(title: String, message: String, date: NSDate?, userInfo: NSDictionary?, soundName: String?, hasAction: Bool) -> UILocalNotification {
        let notification = UILocalNotification()
        notification.alertAction = title
        notification.alertBody = message
        notification.userInfo = userInfo as! [AnyHashable : Any]?
        notification.soundName = soundName ?? UILocalNotificationDefaultSoundName
        notification.fireDate = date as Date?
        notification.hasAction = hasAction
        return notification
    }
    
    func getAllNotifications() -> [UILocalNotification]? {
        return UIApplication.shared.scheduledLocalNotifications
    }
    
    func cancelAllNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    func registerUserNotificationWithActionButtons(actions : [UIUserNotificationAction]){
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = LOCAL_NOTIFICATION_CATEGORY
        
        category.setActions(actions, for: UIUserNotificationActionContext.default)
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: NSSet(object: category) as? Set<UIUserNotificationCategory>)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    func registerUserNotification(){
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    func createUserNotificationActionButton(identifier : String, title : String) -> UIUserNotificationAction{
        
        let actionButton = UIMutableUserNotificationAction()
        actionButton.identifier = identifier
        actionButton.title = title
        actionButton.activationMode = UIUserNotificationActivationMode.background
        actionButton.isAuthenticationRequired = true
        actionButton.isDestructive = false
        
        return actionButton
    }
    
}

/// EZSwiftExtensions
private let DeviceList = [
    /* iPod 5 */          "iPod5,1": "iPod Touch 5",
                          /* iPod 6 */          "iPod7,1": "iPod Touch 6",
                                                /* iPhone 4 */        "iPhone3,1":  "iPhone 4", "iPhone3,2": "iPhone 4", "iPhone3,3": "iPhone 4",
                                                                      /* iPhone 4S */       "iPhone4,1": "iPhone 4S",
                                                                                            /* iPhone 5 */        "iPhone5,1": "iPhone 5", "iPhone5,2": "iPhone 5",
                                                                                                                  /* iPhone 5C */       "iPhone5,3": "iPhone 5C", "iPhone5,4": "iPhone 5C",
                                                                                                                                        /* iPhone 5S */       "iPhone6,1": "iPhone 5S", "iPhone6,2": "iPhone 5S",
                                                                                                                                                              /* iPhone 6 */        "iPhone7,2": "iPhone 6",
                                                                                                                                                                                    /* iPhone 6 Plus */   "iPhone7,1": "iPhone 6 Plus",
                                                                                                                                                                                                          /* iPhone 6S */       "iPhone8,1": "iPhone 6S",
                                                                                                                                                                                                                                /* iPhone 6S Plus */  "iPhone8,2": "iPhone 6S Plus",
                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                      /* iPad 2 */          "iPad2,1": "iPad 2", "iPad2,2": "iPad 2", "iPad2,3": "iPad 2", "iPad2,4": "iPad 2",
                                                                                                                                                                                                                                                                            /* iPad 3 */          "iPad3,1": "iPad 3", "iPad3,2": "iPad 3", "iPad3,3": "iPad 3",
                                                                                                                                                                                                                                                                                                  /* iPad 4 */          "iPad3,4": "iPad 4", "iPad3,5": "iPad 4", "iPad3,6": "iPad 4",
                                                                                                                                                                                                                                                                                                                        /* iPad Air */        "iPad4,1": "iPad Air", "iPad4,2": "iPad Air", "iPad4,3": "iPad Air",
                                                                                                                                                                                                                                                                                                                                              /* iPad Air 2 */      "iPad5,3": "iPad Air 2", "iPad5,4": "iPad Air 2",
                                                                                                                                                                                                                                                                                                                                                                    /* iPad Mini */       "iPad2,5": "iPad Mini", "iPad2,6": "iPad Mini", "iPad2,7": "iPad Mini",
                                                                                                                                                                                                                                                                                                                                                                                          /* iPad Mini 2 */     "iPad4,4": "iPad Mini 2", "iPad4,5": "iPad Mini 2", "iPad4,6": "iPad Mini 2",
                                                                                                                                                                                                                                                                                                                                                                                                                /* iPad Mini 3 */     "iPad4,7": "iPad Mini 3", "iPad4,8": "iPad Mini 3", "iPad4,9": "iPad Mini 3",
                                                                                                                                                                                                                                                                                                                                                                                                                                      /* iPad Mini 4 */     "iPad5,1": "iPad Mini 4", "iPad5,2": "iPad Mini 4",
                                                                                                                                                                                                                                                                                                                                                                                                                                                            /* iPad Pro */        "iPad6,7": "iPad Pro", "iPad6,8": "iPad Pro",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  /* AppleTV */         "AppleTV5,3": "AppleTV",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        /* Simulator */       "x86_64": "Simulator", "i386": "Simulator"
]


extension UIDevice {
    /// EZSwiftExtensions
    public class func idForVendor() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    /// EZSwiftExtensions - Operating system name
    public class func systemName() -> String {
        return UIDevice.current.systemName
    }
    
    /// EZSwiftExtensions - Operating system version
    public class func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    /// EZSwiftExtensions - Operating system version
    public class func systemFloatVersion() -> Float {
        return (systemVersion() as NSString).floatValue
    }
    
    /// EZSwiftExtensions
    public class func deviceName() -> String {
        return UIDevice.current.name
    }
    
    /// EZSwiftExtensions
    public class func deviceLanguage() -> String {
        return Bundle.main.preferredLocalizations[0]
    }
    
    /// EZSwiftExtensions
    public class func deviceModelReadable() -> String {
        return DeviceList[deviceModel()] ?? deviceModel()
    }
    
    /// EZSE: Returns true if the device is iPhone //TODO: Add to readme
    public class func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
    /// EZSE: Returns true if the device is iPad //TODO: Add to readme
    public class func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    /// EZSwiftExtensions
    public class func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        var identifier = ""
        let mirror = Mirror(reflecting: machine)
        
        for child in mirror.children {
            let value = child.value
            
            if let value = value as? Int8 , value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }
        
        return identifier
    }
    
    //TODO: Fix syntax, add docs and readme for these methods:
    //TODO: Delete isSystemVersionOver() 
    // MARK: - Device Version Checks
    
    public enum Versions: Float {
        case five = 5.0
        case six = 6.0
        case seven = 7.0
        case eight = 8.0
        case nine = 9.0
    }
    
    public class func isVersion(_ version: Versions) -> Bool {
        return systemFloatVersion() >= version.rawValue && systemFloatVersion() < (version.rawValue + 1.0)
    }
    
    public class func isVersionOrLater(_ version: Versions) -> Bool {
        return systemFloatVersion() >= version.rawValue
    }
    
    public class func isVersionOrEarlier(_ version: Versions) -> Bool {
        return systemFloatVersion() < (version.rawValue + 1.0)
    }
    
    public class var CURRENT_VERSION: String {
        return "\(systemFloatVersion())"
    }
    
    // MARK: iOS 5 Checks
    
    public class func IS_OS_5() -> Bool {
        return isVersion(.five)
    }
    
    public class func IS_OS_5_OR_LATER() -> Bool {
        return isVersionOrLater(.five)
    }
    
    public class func IS_OS_5_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.five)
    }
    
    // MARK: iOS 6 Checks
    
    public class func IS_OS_6() -> Bool {
        return isVersion(.six)
    }
    
    public class func IS_OS_6_OR_LATER() -> Bool {
        return isVersionOrLater(.six)
    }
    
    public class func IS_OS_6_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.six)
    }
    
    // MARK: iOS 7 Checks
    
    public class func IS_OS_7() -> Bool {
        return isVersion(.seven)
    }
    
    public class func IS_OS_7_OR_LATER() -> Bool {
        return isVersionOrLater(.seven)
    }
    
    public class func IS_OS_7_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.seven)
    }
    
    // MARK: iOS 8 Checks
    
    public class func IS_OS_8() -> Bool {
        return isVersion(.eight)
    }
    
    public class func IS_OS_8_OR_LATER() -> Bool {
        return isVersionOrLater(.eight)
    }
    
    public class func IS_OS_8_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.eight)
    }
    
    // MARK: iOS 9 Checks
    
    public class func IS_OS_9() -> Bool {
        return isVersion(.nine)
    }
    
    public class func IS_OS_9_OR_LATER() -> Bool {
        return isVersionOrLater(.nine)
    }
    
    public class func IS_OS_9_OR_EARLIER() -> Bool {
        return isVersionOrEarlier(.nine)
    }
    
    /// EZSwiftExtensions
    public class func isSystemVersionOver(_ requiredVersion: String) -> Bool {
        switch systemVersion().compare(requiredVersion, options: NSString.CompareOptions.numeric) {
        case .orderedSame, .orderedDescending:
            //println("iOS >= 8.0")
            return true
        case .orderedAscending:
            //println("iOS < 8.0")
            return false
        }
    }
}

// MARK: - JSONSerializer

open class JSONSerializer {
    
    public enum JSONSerializerError: Error {
        case jsonIsNotDictionary
        case jsonIsNotArray
        case jsonIsNotValid
    }
    
    open static func toDictionary(_ jsonString: String) throws -> NSDictionary {
        if let dictionary = try jsonToAnyObject(jsonString) as? NSDictionary {
            return dictionary
        } else {
            throw JSONSerializerError.jsonIsNotDictionary
        }
    }
    
    open static func toArray(_ jsonString: String) throws -> NSArray {
        if let array = try jsonToAnyObject(jsonString) as? NSArray {
            return array
        } else {
            throw JSONSerializerError.jsonIsNotArray
        }
    }
    
    fileprivate static func jsonToAnyObject(_ jsonString: String) throws -> Any? {
        var any: Any?
        
        if let data = jsonString.data(using: String.Encoding.utf8) {
            do {
                any = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) 
            }
            catch _ as NSError {
                throw JSONSerializerError.jsonIsNotValid
            }
        }
        return any
    }
    
}


public protocol SearchTableViewDataSource : NSObjectProtocol {
    
    func searchPropertyName() -> String
    
}

class SearchTableView : UITableView {
    
    var itemList : [Any] {
        get {
            return getDataSource()
        } set {
            items = newValue
        }
    }
    
    var searchDataSource: SearchTableViewDataSource?
    
    fileprivate var items = [Any]()
    
    fileprivate var searchProperty : String {
        
        guard let searchDataSource = searchDataSource else {
            return ""
        }
        
        return searchDataSource.searchPropertyName()
    }
    
    fileprivate var filteredItems = [Any]()
    let searchController = UISearchController(searchResultsController: .none)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        DispatchQueue.main.async { () -> Void in
            self.searchController.dimsBackgroundDuringPresentation = false
            self.searchController.searchResultsUpdater = self
            self.searchController.searchBar.sizeToFit()
            self.searchController.searchBar.returnKeyType = .done
            self.searchController.searchBar.tintColor = APP_THEME_COLOR
            self.tableHeaderView = self.searchController.searchBar
            let contentOffset = CGPoint(x: 0.0, y: self.contentOffset.y + self.searchController.searchBar.frame.height)
            self.setContentOffset(contentOffset, animated: false)
        }
    }
    
    func disableSearchController(){
        self.closeSearch()
        if self.contentOffset.y < self.searchController.searchBar.frame.height {
            let contentOffset = CGPoint(x: 0.0, y: self.searchController.searchBar.frame.height)
            self.setContentOffset(contentOffset, animated: true)
        }
    }
    
    func enableSearchController(){
    }
    
    fileprivate func getDataSource() -> [Any] {
        return (searchController.isActive) ? filteredItems : items
    }
    
    func closeSearch() {
        resignKeyboard()
        self.searchController.isActive = false
    }
    
}

extension SearchTableView: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Update the filtered array based on the search text.
        let searchResults = items
        
        // Strip out all the leading and trailing spaces.
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: .whitespaces).lowercased()
        
        var filteredResults:[Any]
        if strippedString.length > 0{
            filteredResults = searchResults.filter ({
                if let object = $0 as? AnyObject{
                    if let value = object.value(forKey: searchProperty) {
                        return "\(value)".lowercased().contains(strippedString)
                    }
                }
                return false
            })
        }else{
            filteredResults = searchResults
        }
        
        filteredItems = filteredResults
        reloadData()
    }
    
}

import UIKit
import QuartzCore
import ObjectiveC

enum SLpopupViewAnimationType: Int {
    case bottomTop
    case topBottom
    case bottomBottom
    case topTop
    case leftLeft
    case leftRight
    case rightLeft
    case rightRight
    case fade
}
let kSourceViewTag = 11111
let kpopupViewTag = 22222
let kOverlayViewTag = 22222

var kpopupViewController:UInt8 = 0
var kpopupBackgroundView:UInt8 = 1

let kpopupAnimationDuration = 0.35
let kSLViewDismissKey = "kSLViewDismissKey"

extension UIViewController {
    
    func isBackButtonRequired()->Bool{
        return (self.navigationController != nil) && (self.navigationController!.viewControllers.count > 1)
    }
    
    var popupBackgroundView:UIView? {
        get {
            return objc_getAssociatedObject(self, &kpopupBackgroundView) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kpopupBackgroundView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var popupViewController:UIViewController? {
        get {
            return objc_getAssociatedObject(self, &kpopupViewController) as? UIViewController
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kpopupViewController, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    //    var dismissedCallback:UIViewController? {
    //        get {
    //            return objc_getAssociatedObject(self, kSLViewDismissKey) as? UIViewController
    //        }
    //        set(newValue) {
    //            objc_setAssociatedObject(self, kSLViewDismissKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    //        }
    //    }
    
    func presentpopupViewController(_ popupViewController: UIViewController, animationType:SLpopupViewAnimationType, completion:() -> Void) {
        dismissImmediately()
        
        let sourceView:UIView = self.getTopView()
        self.popupViewController = popupViewController
        let popupView:UIView = popupViewController.view
        sourceView.tag = kSourceViewTag
        popupView.autoresizingMask = [.flexibleTopMargin,.flexibleLeftMargin,.flexibleRightMargin,.flexibleBottomMargin]
        popupView.tag = kpopupViewTag
        if(sourceView.subviews.contains(popupView)) {
            return
        }
        popupView.layer.shadowPath = UIBezierPath(rect: popupView.bounds).cgPath
        popupView.layer.shouldRasterize = true
        popupView.layer.rasterizationScale = UIScreen.main.scale
        
        let overlayView:UIView = UIView(frame: sourceView.bounds)
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.tag = kOverlayViewTag
        overlayView.backgroundColor = UIColor.clear
        
        self.popupBackgroundView = UIView(frame: sourceView.bounds)
        self.popupBackgroundView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.popupBackgroundView!.backgroundColor = UIColor.black
        self.popupBackgroundView?.alpha = 0.0
        if let _ = self.popupBackgroundView {
            overlayView.addSubview(self.popupBackgroundView!)
        }
        //Background is button
        let dismissButton: UIButton = UIButton(type: .custom)
        dismissButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dismissButton.backgroundColor = UIColor.clear
        dismissButton.frame = sourceView.bounds
        overlayView.addSubview(dismissButton)
        
        popupView.alpha = 0.0
        overlayView.addSubview(popupView)
        sourceView.addSubview(overlayView)
        
        dismissButton.addTarget(self, action: #selector(UIViewController.btnDismissViewControllerWithAnimation(_:)), for: .touchUpInside)
        switch animationType {
        case .bottomTop, .bottomBottom,.topTop,.topBottom, .leftLeft, .leftRight,.rightLeft, .rightRight:
            dismissButton.tag = animationType.rawValue
            self.slideView(popupView, sourceView: sourceView, overlayView: overlayView, animationType: animationType)
        default:
            dismissButton.tag = SLpopupViewAnimationType.fade.rawValue
            self.fadeView(popupView, sourceView: sourceView, overlayView: overlayView)
        }
        
    }
    func slideView(_ popupView: UIView, sourceView:UIView, overlayView:UIView, animationType: SLpopupViewAnimationType) {
        let sourceSize: CGSize = sourceView.bounds.size
        let popupSize: CGSize = popupView.bounds.size
        var popupStartRect:CGRect
        switch animationType {
        case .bottomTop, .bottomBottom:
            popupStartRect = CGRect(x: (sourceSize.width - popupSize.width)/2, y: sourceSize.height, width: popupSize.width, height: popupSize.height)
        case .leftLeft, .leftRight:
            popupStartRect = CGRect(x: -sourceSize.width, y: (sourceSize.height - popupSize.height)/2, width: popupSize.width, height: popupSize.height)
        case .topTop, .topBottom:
            popupStartRect = CGRect(x: (sourceSize.width - popupSize.width)/2, y: -sourceSize.height, width: popupSize.width, height: popupSize.height)
        default:
            popupStartRect = CGRect(x: sourceSize.width, y: (sourceSize.height - popupSize.height)/2, width: popupSize.width, height: popupSize.height)
        }
        let popupEndRect:CGRect = CGRect(x: (sourceSize.width - popupSize.width)/2, y: (sourceSize.height - popupSize.height)/2, width: popupSize.width, height: popupSize.height)
        popupView.frame = popupStartRect
        popupView.alpha = 1.0
        UIView.animate(withDuration: kpopupAnimationDuration, animations: { () -> Void in
            self.popupViewController?.viewWillAppear(false)
            self.popupBackgroundView?.alpha = 0.5
            popupView.frame = popupEndRect
        }, completion: { (finished) -> Void in
            self.popupViewController?.viewDidAppear(false)
            self.popupViewController?.view?.removeFromSuperview()
            self.popupViewController = nil
        })
        
    }
    func slideViewOut(_ popupView: UIView, sourceView:UIView, overlayView:UIView, animationType: SLpopupViewAnimationType) {
        let sourceSize: CGSize = sourceView.bounds.size
        let popupSize: CGSize = popupView.bounds.size
        var popupEndRect:CGRect
        switch animationType {
        case .bottomTop, .topTop:
            popupEndRect = CGRect(x: (sourceSize.width - popupSize.width)/2, y: -popupSize.height, width: popupSize.width, height: popupSize.height)
        case .bottomBottom, .topBottom:
            popupEndRect = CGRect(x: (sourceSize.width - popupSize.width)/2, y: popupSize.height, width: popupSize.width, height: popupSize.height)
        case .leftRight, .rightRight:
            popupEndRect = CGRect(x: sourceSize.width, y: popupView.frame.origin.y, width: popupSize.width, height: popupSize.height)
        default:
            popupEndRect = CGRect(x: -popupSize.width, y: popupView.frame.origin.y, width: popupSize.width, height: popupSize.height)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.popupBackgroundView?.backgroundColor = UIColor.clear
        }) { (finished) -> Void in
            UIView.animate(withDuration: kpopupAnimationDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.popupViewController?.viewWillDisappear(false)
                popupView.frame = popupEndRect
            }) { (finished) -> Void in
                popupView.removeFromSuperview()
                overlayView.removeFromSuperview()
                self.popupViewController?.viewDidDisappear(false)
                self.popupViewController?.view?.removeFromSuperview()
                self.popupViewController = nil
            }
        }
        
        
        
    }
    
    func fadeView(_ popupView: UIView, sourceView:UIView, overlayView:UIView) {
        let sourceSize: CGSize = sourceView.bounds.size
        let popupSize: CGSize = popupView.bounds.size
        popupView.frame = CGRect(x: (sourceSize.width - popupSize.width)/2,
                                 y: (sourceSize.height - popupSize.height)/2,
                                 width: popupSize.width,
                                 height: popupSize.height)
        popupView.alpha = 0.0
        
        popupViewController!.view.performAppearAnimationType3()
        UIView.animate(withDuration: kpopupAnimationDuration, animations: { () -> Void in
            self.popupViewController!.viewWillAppear(false)
            self.popupBackgroundView!.alpha = 0.4
            popupView.alpha = 1.0
        }, completion: { (finished) -> Void in
            self.popupViewController?.viewDidAppear(false)
        })
        
    }
    
    func fadeViewOut(_ popupView: UIView, sourceView:UIView, overlayView:UIView) {
        UIView.animate(withDuration: kpopupAnimationDuration, animations: { () -> Void in
            self.popupViewController?.viewDidDisappear(false)
            self.popupBackgroundView?.alpha = 0.0
            popupView.alpha = 0.0
        }, completion: { (finished) -> Void in
            popupView.removeFromSuperview()
            overlayView.removeFromSuperview()
            self.popupViewController?.viewDidDisappear(false)
            self.popupViewController = nil
        })
        
    }
    func btnDismissViewControllerWithAnimation(_ btnDismiss : UIButton) {
        let animationType:SLpopupViewAnimationType = SLpopupViewAnimationType(rawValue: btnDismiss.tag)!
        switch animationType {
        case .bottomTop, .bottomBottom, .topTop, .topBottom, .leftLeft, .leftRight, .rightLeft, .rightRight:
            self.dismissPopupViewController(animationType)
        default:
            self.dismissPopupViewController(SLpopupViewAnimationType.fade)
        }
    }
    func getTopView() -> UIView {
        var recentViewController:UIViewController = self
        if let _ = recentViewController.parent {
            recentViewController = recentViewController.parent!
        }
        return recentViewController.view
    }
    func dismissPopupViewController(_ animationType: SLpopupViewAnimationType) {
        let sourceView:UIView = self.getTopView()
        if isNotNull(sourceView.viewWithTag(kpopupViewTag)){
            let popupView:UIView = sourceView.viewWithTag(kpopupViewTag)!
            let overlayView:UIView = sourceView.viewWithTag(kOverlayViewTag)!
            switch animationType {
            case .bottomTop, .bottomBottom, .topTop, .topBottom, .leftLeft, .leftRight, .rightLeft, .rightRight:
                self.slideViewOut(popupView, sourceView: sourceView, overlayView: overlayView, animationType: animationType)
            default:
                fadeViewOut(popupView, sourceView: sourceView, overlayView: overlayView)
            }
        }
    }
    func isPopUpViewControllerShowing()->Bool {
        let sourceView:UIView = self.getTopView()
        return isNotNull(sourceView.viewWithTag(kpopupViewTag))
    }
    func dismissImmediately() {
        let sourceView:UIView = self.getTopView()
        if isNotNull(sourceView.viewWithTag(kpopupViewTag)){
            let popupView:UIView = sourceView.viewWithTag(kpopupViewTag)!
            let overlayView:UIView = sourceView.viewWithTag(kOverlayViewTag)!
            popupView.removeFromSuperview()
            overlayView.removeFromSuperview()
        }
    }
    func getAddedView() -> UIView? {
        let sourceView:UIView = self.getTopView()
        if isNotNull(sourceView.viewWithTag(kpopupViewTag)){
            return sourceView.viewWithTag(kpopupViewTag)!
        }
        return nil
    }
}


import CoreLocation
import MapKit


typealias DirectionsCompletionHandler = ((_ route:MKPolyline?, _ directionInformation:NSDictionary?, _ boundingRegion:MKMapRect?, _ error:String?)->())?

// TODO: Documentation
class MapManager: NSObject{
    
    fileprivate var directionsCompletionHandler:DirectionsCompletionHandler
    fileprivate let errorNoRoutesAvailable = "No routes available"// add more error handling
    
    fileprivate let errorDictionary = ["NOT_FOUND" : "At least one of the locations specified in the request's origin, destination, or waypoints could not be geocoded",
                                       "ZERO_RESULTS":"No route could be found between the origin and destination",
                                       "MAX_WAYPOINTS_EXCEEDED":"Too many waypointss were provided in the request The maximum allowed waypoints is 8, plus the origin, and destination",
                                       "INVALID_REQUEST":"The provided request was invalid. Common causes of this status include an invalid parameter or parameter value",
                                       "OVER_QUERY_LIMIT":"Service has received too many requests from your application within the allowed time period",
                                       "REQUEST_DENIED":"Service denied use of the directions service by your application",
                                       "UNKNOWN_ERROR":"Directions request could not be processed due to a server error. Please try again"]
    
    override init(){
        super.init()
    }
    
    func directions(_ from:CLLocationCoordinate2D,to:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        self.directionsCompletionHandler = directionCompletionHandler
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(to as String, completionHandler: { (placemarksObject, error) -> Void in
            if let error = error {
                self.directionsCompletionHandler!(nil,nil, nil, error.localizedDescription)
            }
            else {
                let placemark = placemarksObject!.last!
                
                let placemarkSource = MKPlacemark(coordinate: from, addressDictionary: nil)
                
                let source = MKMapItem(placemark: placemarkSource)
                let placemarkDestination = MKPlacemark(placemark: placemark)
                let destination = MKMapItem(placemark: placemarkDestination)
                
                self.directionsFor(source, destination: destination, directionCompletionHandler: directionCompletionHandler)
            }
        })
    }
    
    func directionsFromCurrentLocation(_ to:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        self.directionsCompletionHandler = directionCompletionHandler
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(to as String, completionHandler: { (placemarksObject, error) -> Void in
            if let error = error {
                self.directionsCompletionHandler!(nil,nil, nil, error.localizedDescription)
            }
            else{
                let placemark = placemarksObject!.last!
                let source = MKMapItem.forCurrentLocation()
                let placemarkDestination = MKPlacemark(placemark: placemark)
                let destination = MKMapItem(placemark: placemarkDestination)
                self.directionsFor(source, destination: destination, directionCompletionHandler: directionCompletionHandler)
            }
        })
    }
    
    func directionsFromCurrentLocation(_ to:CLLocationCoordinate2D,directionCompletionHandler:DirectionsCompletionHandler){
        let source = MKMapItem.forCurrentLocation()
        let placemarkDestination = MKPlacemark(coordinate: to, addressDictionary: nil)
        let destination = MKMapItem(placemark: placemarkDestination)
        directionsFor(source, destination: destination, directionCompletionHandler: directionCompletionHandler)
    }
    
    func directions(_ from:CLLocationCoordinate2D, to:CLLocationCoordinate2D,directionCompletionHandler:DirectionsCompletionHandler){
        let placemarkSource = MKPlacemark(coordinate: from, addressDictionary: nil)
        let source = MKMapItem(placemark: placemarkSource)
        let placemarkDestination = MKPlacemark(coordinate: to, addressDictionary: nil)
        let destination = MKMapItem(placemark: placemarkDestination)
        directionsFor(source, destination: destination, directionCompletionHandler: directionCompletionHandler)
    }
    
    fileprivate func directionsFor(_ source:MKMapItem, destination:MKMapItem, directionCompletionHandler:DirectionsCompletionHandler){
        self.directionsCompletionHandler = directionCompletionHandler
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = MKDirectionsTransportType.any
        directionRequest.requestsAlternateRoutes = true
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {
            (response:MKDirectionsResponse?, error:NSError?) -> Void in
            if let error = error {
                self.directionsCompletionHandler!(nil,nil, nil, error.localizedDescription)
            }
            else if response!.routes.isEmpty {
                self.directionsCompletionHandler!(nil,nil, nil, self.errorNoRoutesAvailable)
            }
            else{
                let route: MKRoute = response!.routes[0]
                let steps = route.steps as NSArray
                let end_address = route.name
                let distance = route.distance.description
                let duration = route.expectedTravelTime.description
                
                let source = response!.source.placemark.coordinate
                let destination = response!.destination.placemark.coordinate
                
                let start_location = ["lat":source.latitude,"lng":source.longitude]
                let end_location = ["lat":destination.latitude,"lng":destination.longitude]
                
                let stepsFinalArray = NSMutableArray()
                
                steps.enumerateObjects({ (obj, idx, stop) -> Void in
                    let step:MKRouteStep = obj as! MKRouteStep
                    let distance = step.distance.description
                    let instructions = step.instructions
                    let stepsDictionary = NSMutableDictionary()
                    
                    stepsDictionary.setObject(distance, forKey: "distance" as NSCopying)
                    stepsDictionary.setObject("", forKey: "duration" as NSCopying)
                    stepsDictionary.setObject(instructions, forKey: "instructions" as NSCopying)
                    
                    stepsFinalArray.add(stepsDictionary)
                })
                
                let stepsDict = NSMutableDictionary()
                stepsDict.setObject(distance, forKey: "distance" as NSCopying)
                stepsDict.setObject(duration, forKey: "duration" as NSCopying)
                stepsDict.setObject(end_address, forKey: "end_address" as NSCopying)
                stepsDict.setObject(end_location, forKey: "end_location" as NSCopying)
                stepsDict.setObject("", forKey: "start_address" as NSCopying)
                stepsDict.setObject(start_location, forKey: "start_location" as NSCopying)
                stepsDict.setObject(stepsFinalArray, forKey: "steps" as NSCopying)
                
                self.directionsCompletionHandler!(route.polyline,stepsDict, route.polyline.boundingMapRect, nil)
            }
            } as! MKDirectionsHandler)
    }
    
    /**
     Get directions using Google API by passing source and destination as string.
     - parameter from: Starting point of journey
     - parameter to: Ending point of journey
     - returns: directionCompletionHandler: Completion handler contains polyline,dictionary,maprect and error
     */
    func directionsUsingGoogle(_ from:NSString, to:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        getDirectionsUsingGoogle(from, destination: to, directionCompletionHandler: directionCompletionHandler)
    }
    
    func directionsUsingGoogle(_ from:CLLocationCoordinate2D, to:CLLocationCoordinate2D,directionCompletionHandler:DirectionsCompletionHandler){
        let originLatLng = "\(from.latitude),\(from.longitude)"
        let destinationLatLng = "\(to.latitude),\(to.longitude)"
        getDirectionsUsingGoogle(originLatLng as NSString, destination: destinationLatLng as NSString, directionCompletionHandler: directionCompletionHandler)
        
    }
    
    func directionsUsingGoogle(_ from:CLLocationCoordinate2D, to:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        let originLatLng = "\(from.latitude),\(from.longitude)"
        getDirectionsUsingGoogle(originLatLng as NSString, destination: to, directionCompletionHandler: directionCompletionHandler)
    }
    
    fileprivate func getDirectionsUsingGoogle(_ origin:NSString, destination:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        self.directionsCompletionHandler = directionCompletionHandler
        let path = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&sensor=false&units=metric&mode=driving&key=\(GOOGLE_API_KEY)"
        performOperationForURL(path as NSString)
    }
    
    fileprivate func performOperationForURL(_ urlString:NSString){
        let urlEncoded = urlString.replacingOccurrences(of: " ", with: "%20")
        let url:URL? = URL(string:urlEncoded)
        let request:URLRequest = URLRequest(url:url!)
        let queue:OperationQueue = OperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request,queue:queue,completionHandler:{response,data,error in
            if error != nil {
                logMessage(error!.localizedDescription)
                self.directionsCompletionHandler!(nil,nil, nil, error!.localizedDescription)
            }
            else{
                let jsonResult: NSDictionary = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                let routes = jsonResult.object(forKey: "routes") as! NSArray
                let status = jsonResult.object(forKey: "status") as! NSString
                var route = routes.lastObject as? NSDictionary //first object?
                if route == nil {
                    route = NSDictionary()
                }
                if status.isEqual(to: "OK") && route!.allKeys.count > 0  {
                    let legs = route!.object(forKey: "legs") as! NSArray
                    let steps = legs.firstObject as! NSDictionary
                    let directionInformation = self.parser(steps) as NSDictionary
                    let overviewPolyline = route!.object(forKey: "overview_polyline") as! NSDictionary
                    let points = overviewPolyline.object(forKey: "points") as! NSString
                    let locations = self.decodePolyLine(points) as Array
                    var coordinates = locations.map({ (location: CLLocation) ->
                        CLLocationCoordinate2D in
                        return location.coordinate
                    })
                    let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
                    self.directionsCompletionHandler!(polyline,directionInformation, polyline.boundingMapRect, nil)
                }
                else{
                    var errorMsg = self.errorDictionary[status as String]
                    if errorMsg == nil {
                        errorMsg = self.errorNoRoutesAvailable
                    }
                    self.directionsCompletionHandler!(nil,nil, nil, errorMsg)
                }
            }
        }
        )
    }
    
    fileprivate func decodePolyLine(_ encodedStr:NSString)->Array<CLLocation>{
        var array = Array<CLLocation>()
        let len = encodedStr.length
        let range = NSMakeRange(0, len)
        var strpolyline = encodedStr
        var index = 0
        var lat = 0 as Int32
        var lng = 0 as Int32
        
        strpolyline = encodedStr.replacingOccurrences(of: "\\\\", with: "\\", options: NSString.CompareOptions.literal, range: range) as NSString
        while(index<len){
            var b = 0
            var shift = 0
            var result = 0
            repeat {
                var numUnichar : unichar = 0
                    index = index+1
                    numUnichar = strpolyline.character(at: index-1)
                let num =  NSNumber(value: numUnichar as UInt16)
                let numInt = num.intValue
                b = numInt - 63
                result |= (b & 0x1f) << shift
                shift += 5
            } while(b >= 0x20)
            
            var dlat = 0
            
            if((result & 1) == 1){
                dlat = ~(result >> 1)
            }
            else{
                dlat = (result >> 1)
            }
            
            lat += dlat
            
            shift = 0
            result = 0
            
            repeat {
                var numUnichar : unichar = 0
                index = index + 1
                numUnichar = strpolyline.character(at: index-1)
                let num =  NSNumber(value: numUnichar as UInt16)
                let numInt = num.intValue
                b = numInt - 63
                result |= (b & 0x1f) << shift
                shift += 5
            } while(b >= 0x20)
            
            var dlng = 0
            
            if((result & 1) == 1){
                dlng = ~(result >> 1)
            }
            else{
                dlng = (result >> 1)
            }
            lng += dlng
            
            let latitude = NSNumber(value: lat as Int32).doubleValue * 1e-5
            let longitude = NSNumber(value: lng as Int32).doubleValue * 1e-5
            let location = CLLocation(latitude: latitude, longitude: longitude)
            array.append(location)
        }
        return array
    }
    
    fileprivate func parser(_ data:NSDictionary)->NSDictionary{
        let distance = (data.object(forKey: "distance") as! NSDictionary).object(forKey: "text") as! NSString
        let duration = (data.object(forKey: "duration") as! NSDictionary).object(forKey: "text") as! NSString
        let end_address = data.object(forKey: "end_address") as! NSString
        let end_location = data.object(forKey: "end_location") as! NSDictionary
        let start_address = data.object(forKey: "start_address") as! NSString
        let start_location = data.object(forKey: "start_location") as! NSDictionary
        let stepsArray = data.object(forKey: "steps") as! NSArray
        let stepsDict = NSMutableDictionary()
        let stepsFinalArray = NSMutableArray()
        
        stepsArray.enumerateObjects({ (obj, idx, stop) -> Void in
            let stepDict = obj as! NSDictionary
            let distance = (stepDict.object(forKey: "distance") as! NSDictionary).object(forKey: "text") as! NSString
            let duration = (stepDict.object(forKey: "duration") as! NSDictionary).object(forKey: "text") as! NSString
            let html_instructions = stepDict.object(forKey: "html_instructions") as! NSString
            let end_location = stepDict.object(forKey: "end_location") as! NSDictionary
            let instructions = self.removeHTMLTags((stepDict.object(forKey: "html_instructions") as! NSString))
            let start_location = stepDict.object(forKey: "start_location") as! NSDictionary
            let stepsDictionary = NSMutableDictionary()
            stepsDictionary.setObject(distance, forKey: "distance" as NSCopying)
            stepsDictionary.setObject(duration, forKey: "duration" as NSCopying)
            stepsDictionary.setObject(html_instructions, forKey: "html_instructions" as NSCopying)
            stepsDictionary.setObject(end_location, forKey: "end_location" as NSCopying)
            stepsDictionary.setObject(instructions, forKey: "instructions" as NSCopying)
            stepsDictionary.setObject(start_location, forKey: "start_location" as NSCopying)
            stepsFinalArray.add(stepsDictionary)
        })
        stepsDict.setObject(distance, forKey: "distance" as NSCopying)
        stepsDict.setObject(duration, forKey: "duration" as NSCopying)
        stepsDict.setObject(end_address, forKey: "end_address" as NSCopying)
        stepsDict.setObject(end_location, forKey: "end_location" as NSCopying)
        stepsDict.setObject(start_address, forKey: "start_address" as NSCopying)
        stepsDict.setObject(start_location, forKey: "start_location" as NSCopying)
        stepsDict.setObject(stepsFinalArray, forKey: "steps" as NSCopying)
        return stepsDict
    }
    
    fileprivate func removeHTMLTags(_ source:NSString)->NSString{
        var range = NSMakeRange(0, 0)
        let HTMLTags = "<[^>]*>"
        
        var sourceString = source
        while( sourceString.range(of: HTMLTags, options: NSString.CompareOptions.regularExpression).location != NSNotFound){
            range = sourceString.range(of: HTMLTags, options: NSString.CompareOptions.regularExpression)
            sourceString = sourceString.replacingCharacters(in: range, with: "") as NSString
        }
        return sourceString;
    }
}

import Foundation
import UIKit

@IBDesignable
open class EmojiRateView: UIView {
    /// Rate default color for rateValue = 5
    fileprivate static let rateLineColorBest: UIColor = UIColor.init(hue: 165 / 360, saturation: 0.8, brightness: 0.9, alpha: 1.0)
    
    /// Rate default color for rateValue = 0
    fileprivate static let rateLineColorWorst: UIColor = UIColor.init(hue: 1, saturation: 0.8, brightness: 0.9, alpha: 1.0)
    
    // MARK: -
    // MARK: Private property.
    
    fileprivate var shapeLayer: CAShapeLayer = CAShapeLayer.init()
    fileprivate var shapePath: UIBezierPath = UIBezierPath.init()
    
    fileprivate var rateFaceMargin: CGFloat = 1
    fileprivate var touchPoint: CGPoint? = nil
    fileprivate var hueFrom: CGFloat = 0, saturationFrom: CGFloat = 0, brightnessFrom: CGFloat = 0, alphaFrom: CGFloat = 0
    fileprivate var hueDelta: CGFloat = 0, saturationDelta: CGFloat = 0, brightnessDelta: CGFloat = 0, alphaDelta: CGFloat = 0
    
    // MARK: -
    // MARK: Public property.
    
    /// Line width.
    @IBInspectable open var rateLineWidth: CGFloat = 14 {
        didSet {
            if rateLineWidth > 20 {
                rateLineWidth = 20
            }
            if rateLineWidth < 0.5 {
                rateLineWidth = 0.5
            }
            self.rateFaceMargin = rateLineWidth / 2
            redraw()
        }
    }
    
    /// Current line color.
    @IBInspectable open var rateColor: UIColor = UIColor.init(red: 55 / 256, green: 46 / 256, blue: 229 / 256, alpha: 1.0) {
        didSet {
            redraw()
        }
    }
    
    /// Color range
    open var rateColorRange: (from: UIColor, to: UIColor) = (EmojiRateView.rateLineColorWorst, EmojiRateView.rateLineColorBest) {
        didSet {
            // Get begin color
            rateColorRange.from.getHue(&hueFrom, saturation: &saturationFrom, brightness: &brightnessFrom, alpha: &alphaFrom)
            
            // Get end color
            var hueTo: CGFloat = 1, saturationTo: CGFloat = 1, brightnessTo: CGFloat = 1, alphaTo: CGFloat = 1
            rateColorRange.to.getHue(&hueTo, saturation: &saturationTo, brightness: &brightnessTo, alpha: &alphaTo)
            
            // Update property
            hueDelta = hueTo - hueFrom
            saturationDelta = saturationTo - saturationFrom
            brightnessDelta = brightnessTo - brightnessFrom
            alphaDelta = alphaTo - alphaFrom
            
            // Force to refresh current color
            let currentRateValue = rateValue
            rateValue = currentRateValue
        }
    }
    
    /// If line color changes with rateValue.
    @IBInspectable open var rateDynamicColor: Bool = true {
        didSet {
            redraw()
        }
    }
    
    /// Mouth width. From 0.2 to 0.7.
    @IBInspectable open var rateMouthWidth: CGFloat = 0.6 {
        didSet {
            if rateMouthWidth > 0.7 {
                rateMouthWidth = 0.7
            }
            if rateMouthWidth < 0.2 {
                rateMouthWidth = 0.2
            }
            redraw()
        }
    }
    
    /// Mouth lip width. From 0.2 to 0.9
    @IBInspectable open var rateLipWidth: CGFloat = 0.7 {
        didSet {
            if rateLipWidth > 0.9 {
                rateLipWidth = 0.9
            }
            if rateLipWidth < 0.2 {
                rateLipWidth = 0.2
            }
            redraw()
        }
    }
    
    /// Mouth vertical position. From 0.1 to 0.5.
    @IBInspectable open var rateMouthVerticalPosition: CGFloat = 0.35 {
        didSet {
            if rateMouthVerticalPosition > 0.5 {
                rateMouthVerticalPosition = 0.5
            }
            if rateMouthVerticalPosition < 0.1 {
                rateMouthVerticalPosition = 0.1
            }
            redraw()
        }
    }
    
    /// If show eyes.
    @IBInspectable open var rateShowEyes: Bool = true {
        didSet {
            redraw()
        }
    }
    
    /// Eye width. From 0.1 to 0.3.
    @IBInspectable open var rateEyeWidth: CGFloat = 0.2 {
        didSet {
            if rateEyeWidth > 0.3 {
                rateEyeWidth = 0.3
            }
            if rateEyeWidth < 0.1 {
                rateEyeWidth = 0.1
            }
            redraw()
        }
    }
    
    /// Eye vertical position. From 0.6 to 0.8.
    @IBInspectable open var rateEyeVerticalPosition: CGFloat = 0.6 {
        didSet {
            if rateEyeVerticalPosition > 0.8 {
                rateEyeVerticalPosition = 0.8
            }
            if rateEyeVerticalPosition < 0.6 {
                rateEyeVerticalPosition = 0.6
            }
            redraw()
        }
    }
    
    /// Rate value. From 0 to 5.
    @IBInspectable open var rateValue: Float = 2.5 {
        didSet {
            if rateValue > 5 {
                rateValue = 5
            }
            if rateValue < 0 {
                rateValue = 0
            }
            
            // Update color
            if rateDynamicColor {
                let rate: CGFloat = CGFloat(rateValue / 5)
                
                // Calculate new color
                self.rateColor = UIColor.init(
                    hue: hueFrom + hueDelta * rate,
                    saturation: saturationFrom + saturationDelta * rate,
                    brightness: brightnessFrom + brightnessDelta * rate,
                    alpha: alphaFrom + alphaDelta * rate)
            }
            
            // Callback
            self.rateValueChangeCallback?(rateValue)
            
            redraw()
        }
    }
    
    /// Callback when rateValue changes.
    open var rateValueChangeCallback: ((_ newRateValue: Float) -> Void)? = nil
    
    /// Sensitivity when drag. From 1 to 10.
    open var rateDragSensitivity: CGFloat = 5 {
        didSet {
            if rateDragSensitivity > 10 {
                rateDragSensitivity = 10
            }
            if rateDragSensitivity < 1 {
                rateDragSensitivity = 1
            }
        }
    }
    
    // MARK: -
    // MARK: Public methods.
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    /**
     Override layoutSubviews
     */
    open override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }
    
    // MARK: -
    // MARK: Private methods.
    
    /**
     Init configure.
     */
    fileprivate func configure() {
        self.backgroundColor = self.backgroundColor ?? UIColor.white
        self.clearsContextBeforeDrawing = true
        self.isMultipleTouchEnabled = false
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        rateColorRange = (EmojiRateView.rateLineColorWorst, EmojiRateView.rateLineColorBest)
        
        self.layer.addSublayer(shapeLayer)
        redraw()
    }
    
    /**
     Redraw all lines.
     */
    fileprivate func redraw() {
        shapeLayer.frame = self.bounds
        shapeLayer.strokeColor = rateColor.cgColor;
        shapeLayer.lineCap = "round"
        shapeLayer.lineWidth = rateLineWidth
        
        shapePath.removeAllPoints()
        shapePath.append(facePathWithRect(self.bounds))
        shapePath.append(mouthPathWithRect(self.bounds))
        shapePath.append(eyePathWithRect(self.bounds, isLeftEye: true))
        shapePath.append(eyePathWithRect(self.bounds, isLeftEye: false))
        
        shapeLayer.path = shapePath.cgPath
        self.setNeedsDisplay()
    }
    
    /**
     Generate face UIBezierPath
     
     - parameter rect: rect
     
     - returns: face UIBezierPath
     */
    fileprivate func facePathWithRect(_ rect: CGRect) -> UIBezierPath {
        let margin = rateFaceMargin + 2
        let facePath = UIBezierPath(ovalIn: UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(margin, margin, margin, margin)))
        return facePath
    }
    
    /**
     Generate mouth UIBezierPath
     
     - parameter rect: rect
     
     - returns: mouth UIBezierPath
     */
    fileprivate func mouthPathWithRect(_ rect: CGRect) -> UIBezierPath {
        let width = rect.width
        let height = rect.width
        
        let leftPoint = CGPoint(
            x: width * (1 - rateMouthWidth) / 2,
            y: height * (1 - rateMouthVerticalPosition))
        
        let rightPoint = CGPoint(
            x: width - leftPoint.x,
            y: leftPoint.y)
        
        let centerPoint = CGPoint(
            x: width / 2,
            y: leftPoint.y + height * 0.3 * (CGFloat(rateValue) - 2.5) / 5)
        
        let halfLipWidth = width * rateMouthWidth * rateLipWidth / 2
        
        let mouthPath = UIBezierPath()
        mouthPath.move(to: leftPoint)
        
        mouthPath.addCurve(
            to: centerPoint,
            controlPoint1: leftPoint,
            controlPoint2: CGPoint(x: centerPoint.x - halfLipWidth, y: centerPoint.y))
        
        mouthPath.addCurve(
            to: rightPoint,
            controlPoint1: CGPoint(x: centerPoint.x + halfLipWidth, y: centerPoint.y),
            controlPoint2: rightPoint)
        
        return mouthPath
    }
    
    /**
     Generate eye UIBezierPath
     
     - parameter rect:      rect
     - parameter isLeftEye: is left eye
     
     - returns: eye UIBezierPath
     */
    fileprivate func eyePathWithRect(_ rect: CGRect, isLeftEye: Bool) -> UIBezierPath {
        if !rateShowEyes {
            return UIBezierPath.init()
        }
        
        let width = rect.width
        let height = rect.width
        
        let centerPoint = CGPoint(
            x: width * (isLeftEye ? 0.30 : 0.70),
            y: height * (1 - rateEyeVerticalPosition) - height * 0.1 * (CGFloat(rateValue > 2.5 ? rateValue : 2.5) - 2.5) / 5)
        
        let leftPoint = CGPoint(
            x: centerPoint.x - rateEyeWidth / 2 * width,
            y: height * (1 - rateEyeVerticalPosition))
        
        let rightPoint = CGPoint(
            x: centerPoint.x + rateEyeWidth / 2 * width,
            y: leftPoint.y)
        
        let eyePath = UIBezierPath()
        eyePath.move(to: leftPoint)
        
        eyePath.addCurve(
            to: centerPoint,
            controlPoint1: leftPoint,
            controlPoint2: CGPoint(x: centerPoint.x - width * 0.06, y: centerPoint.y))
        
        eyePath.addCurve(
            to: rightPoint,
            controlPoint1: CGPoint(x: centerPoint.x + width * 0.06, y: centerPoint.y),
            controlPoint2: rightPoint)
        
        return eyePath;
    }
    
    // MARK: Touch methods.
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPoint = touches.first?.location(in: self)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentPoint = touches.first?.location(in: self)
        // Change rate value
        rateValue = rateValue + Float((currentPoint!.y - touchPoint!.y) / self.bounds.height * rateDragSensitivity)
        // Save current point
        touchPoint = currentPoint
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPoint = nil
    }
}

private class RSDotView: UIView {
    var fillColor:UIColor = UIColor.black
    var diameter:CGFloat = CGFloat(1)
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        self.fillColor.setFill()
        context!.addEllipse(in: (CGRect (x: 0, y: 0, width: diameter, height: diameter)))
        context!.drawPath(using: CGPathDrawingMode.fill)
        context!.strokePath()
    }
}


class RSDotsView: UIView {
    
    var dotsColor:UIColor = UIColor.black {
        didSet {
            buildView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        buildView()
    }
    
    
    
    fileprivate func buildView() {
        self.layer.cornerRadius = self.bounds.size.width/2;
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        let numberDots = CGFloat(3)
        let width = (self.bounds.size.width)/(numberDots+1)
        let margin = (self.bounds.size.width - (width * numberDots)) / 1.3
        let dotDiameter = width/3
        var frame = CGRect(x: margin, y: self.bounds.size.height/2 - dotDiameter/2, width: dotDiameter, height: dotDiameter);
        
        for _ in 0...Int(numberDots-1) {
            let dot = RSDotView(frame: frame)
            dot.diameter = frame.size.width;
            dot.fillColor = self.dotsColor;
            dot.backgroundColor = UIColor.clear
            
            self.addSubview(dot)
            frame.origin.x += width
        }
        
        self.layoutIfNeeded()
    }
    
    func startAnimating() {
        var i:Int = 0
        for dot in self.subviews as! [RSDotView] {
            dot.transform = CGAffineTransform(scaleX: 0.01, y: 0.01);
            let delay = 0.1*Double(i)
            UIView.animate(withDuration: Double(0.5), delay:delay, options: [.repeat, .autoreverse], animations: { () -> Void in
                dot.transform = CGAffineTransform(scaleX: 1, y: 1)
                dot.layer.layoutIfNeeded()
            }, completion: nil)
            
            i += 1;
        }
    }
    
    
    func stopAnimating() {
        for dot in self.subviews as! [RSDotView] {
            dot.transform = CGAffineTransform(scaleX: 1, y: 1);
            dot.layer.removeAllAnimations()
        }
    }
    
}


@IBDesignable
open class UITags: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBInspectable open var tagColor: UIColor?
    @IBInspectable open var tagSelectedColor: UIColor?
    
    @IBInspectable open var fontSize: CGFloat = 11.0
    @IBInspectable open var fontFamily = "System"
    @IBInspectable open var textColor: UIColor?
    @IBInspectable open var textColorSelected: UIColor?
    
    @IBInspectable open var tagHorizontalDistance: CGFloat = 2
    @IBInspectable open var tagVerticalDistance: CGFloat = 3
    
    @IBInspectable open var horizontalPadding: CGFloat = 3
    @IBInspectable open var verticalPadding: CGFloat = 2
    @IBInspectable open var tagCornerRadius: CGFloat = 3
    
    
    open var collectionView: UICollectionView?
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.tags = ["This", "is","a", "demo","for", "storyboard",".", "Please","make", "an","outlet", "and", "specify", "your", "own", "tags"]
    }
    
    open var delegate: UITagsViewDelegate?
    
    open var tags: [String] = [] {
        didSet {
            self.selectedTags.removeAll()
            self.createTags()
        }
    }
    
    open var selectedTags = [Int]()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    fileprivate var contentHeight: CGFloat = 0.0
    
    fileprivate func setUp() {
        let centeredFlowLayout = KTCenterFlowLayout()
        centeredFlowLayout.minimumInteritemSpacing = 10.0
        centeredFlowLayout.minimumLineSpacing = 10.0
        collectionView = UICollectionView(frame: self.bounds,collectionViewLayout:centeredFlowLayout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.register(UITagCollectionViewCell.self, forCellWithReuseIdentifier: "tagCell")
        if let collectionView = collectionView {
            self.addSubview(collectionView)
            self.layoutSubviews()
        }
    }
    
    fileprivate func createTags() {
        collectionView?.reloadData()
        layoutSubviews()
    }
    
    open override var intrinsicContentSize : CGSize {
        let size = CGSize(width: frame.width, height: contentHeight)
        return size
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        collectionView?.frame = bounds
        collectionView?.layoutSubviews()
        contentHeight = calculatedHeight()
        invalidateIntrinsicContentSize()
    }
    
    //MARK: - collection view dataSource implemantation
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return configureCell(collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath), cellForItemAtIndexPath: indexPath)
    }
    
    fileprivate func configureCell(_ cell: UICollectionViewCell, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellToConfigure = cell as? UITagCollectionViewCell else {
            logMessage("Could not load UITagCollectionViewCell..")
            return UICollectionViewCell()
        }
        cellToConfigure.cornerRadiusToUse = self.tagCornerRadius
        cellToConfigure.fontFamily = self.fontFamily
        cellToConfigure.fontSize = self.fontSize
        cellToConfigure.textColor = self.selectedTags.contains((indexPath as NSIndexPath).row) ? self.textColorSelected : self.textColor
        cellToConfigure.contentView.backgroundColor = self.selectedTags.contains((indexPath as NSIndexPath).row) ? self.tagSelectedColor : self.tagColor
        cellToConfigure.title = self.tags[(indexPath as NSIndexPath).row]
        return cellToConfigure
    }
    
    //MARK: - util methods
    fileprivate func sizeForCellAt(_ indexPath:IndexPath) -> CGSize {
        let tempLabel = UILabel()
        tempLabel.text = self.tags[(indexPath as NSIndexPath).row]
        tempLabel.font = UIFont(name: fontFamily, size: fontSize)
        tempLabel.textColor = textColor
        tempLabel.textAlignment = .center
        
        var size = tempLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        size.height += 2 * verticalPadding
        size.width += 2 * horizontalPadding
        
        return size
    }
    
    fileprivate func calculatedHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        
        let numberOfTags = collectionView!.numberOfItems(inSection: 0)
        
        let maximumRowWidth = frame.size.width
        
        var currentRowWidth: CGFloat = 0.0
        for var tagIndex in 0..<numberOfTags {
            
            var cellSize = sizeForCellAt(IndexPath(item: tagIndex, section: 0))
            cellSize.height += tagVerticalDistance
            cellSize.width += tagHorizontalDistance
            
            if currentRowWidth == 0 {
                totalHeight += cellSize.height
            }
            
            currentRowWidth += cellSize.width
            
            if maximumRowWidth - currentRowWidth < cellSize.width {
                currentRowWidth = 0
                tagIndex -= 1
                continue
            }
        }
        return totalHeight
    }
    
    //MARK: - collectionview flow layout delegate implementation
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForCellAt(indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.tagHorizontalDistance
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.tagVerticalDistance
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    //MARK: - collection view delegate implementation
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedTags.contains((indexPath as NSIndexPath).row) {
            self.selectedTags.removeObject((indexPath as NSIndexPath).row)
            self.delegate?.tagDeselected(atIndex: (indexPath as NSIndexPath).row)
        } else {
            self.selectedTags += [(indexPath as NSIndexPath).row]
            self.delegate?.tagSelected(atIndex: (indexPath as NSIndexPath).row)
        }
        
        self.configureCell(self.collectionView!.cellForItem(at: indexPath)!, cellForItemAtIndexPath: indexPath)
    }
}

private extension Array where Element: Equatable {
    mutating func removeObjectsInArray(_ array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}

public protocol UITagsViewDelegate {
    func tagSelected(atIndex index:Int) -> Void
    func tagDeselected(atIndex index:Int) -> Void
}


class UITagCollectionViewCell: UICollectionViewCell {
    
    var title = "" {
        didSet {
            self.titleLabelRef?.font = UIFont(name: fontFamily, size: fontSize)
            self.titleLabelRef?.textColor = textColor
            self.titleLabelRef?.textAlignment = .center
            self.titleLabelRef?.text = title
        }
    }
    var fontSize: CGFloat = 11.0
    var fontFamily = "System"
    var textColor: UIColor?
    var cornerRadiusToUse: CGFloat = 3.0
    
    fileprivate weak var titleLabelRef: UILabel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let titleLabel = UILabel(frame: bounds)
        titleLabelRef = titleLabel
        titleLabelRef?.font = UIFont(name: fontFamily, size: fontSize)
        titleLabelRef?.textColor = textColor
        titleLabelRef?.textAlignment = .center
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabelRef?.frame = bounds
        contentView.layer.cornerRadius = cornerRadiusToUse
    }
}

extension UIView {
    public func CsetScale(_ x: CGFloat, y: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = CGFloat(1.0) / -1000.0
        transform = CATransform3DScale(transform, x, y, 1)
        self.layer.transform = transform
    }
    
    public func CustomPop() {
        CsetScale(1.2, y: 1.2)
        Cspring(0.2, animations: { [unowned self] () -> Void in
            self.CsetScale(1, y: 1)
        })
    }
    
    public func Cspring(_ duration: TimeInterval, animations: @escaping (() -> Void), completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.allowAnimatedContent, animations: animations, completion: completion)
    }
}


// data source
public typealias NextViewHandler = () -> UIView?
public typealias PreviousViewHandler = () -> UIView?

// customization
public typealias AnimateViewHandler = (_ view: UIView, _ index: Int, _ views: [UIView], _ swipeableView: ZLSwipeableView) -> ()
public typealias InterpretDirectionHandler = (_ topView: UIView, _ direction: Direction, _ views: [UIView], _ swipeableView: ZLSwipeableView) -> (CGPoint, CGVector)
public typealias ShouldSwipeHandler = (_ view: UIView, _ movement: Movement, _ swipeableView: ZLSwipeableView) -> Bool

// delegates
public typealias DidStartHandler = (_ view: UIView, _ atLocation: CGPoint) -> ()
public typealias SwipingHandler = (_ view: UIView, _ atLocation: CGPoint, _ translation: CGPoint) -> ()
public typealias DidEndHandler = (_ view: UIView, _ atLocation: CGPoint) -> ()
public typealias DidSwipeHandler = (_ view: UIView, _ inDirection: Direction, _ directionVector: CGVector) -> ()
public typealias DidCancelHandler = (_ view: UIView) -> ()
public typealias DidTap = (_ view: UIView, _ atLocation: CGPoint) -> ()
public typealias DidDisappear = (_ view: UIView) -> ()

public struct Movement {
    public let location: CGPoint
    public let translation: CGPoint
    public let velocity: CGPoint
}

// MARK: - Main
open class ZLSwipeableView: UIView {
    
    // MARK: Data Source
    open var numberOfActiveView = UInt(4)
    open var nextView: NextViewHandler? {
        didSet {
            loadViews()
        }
    }
    open var previousView: PreviousViewHandler?
    // Rewinding
    open var history = [UIView]()
    open var numberOfHistoryItem = UInt(0)
    
    // MARK: Customizable behavior
    open var animateView = ZLSwipeableView.defaultAnimateViewHandler()
    open var interpretDirection = ZLSwipeableView.defaultInterpretDirectionHandler()
    open var shouldSwipeView = ZLSwipeableView.defaultShouldSwipeViewHandler()
    open var minTranslationInPercent = CGFloat(0.25)
    open var minVelocityInPointPerSecond = CGFloat(750)
    open var allowedDirection = Direction.Horizontal
    open var onlySwipeTopCard = false
    
    // MARK: Delegate
    open var didStart: DidStartHandler?
    open var swiping: SwipingHandler?
    open var didEnd: DidEndHandler?
    open var didSwipe: DidSwipeHandler?
    open var didCancel: DidCancelHandler?
    open var didTap: DidTap?
    open var didDisappear: DidDisappear?
    
    // MARK: Private properties
    /// Contains subviews added by the user.
    fileprivate var containerView = UIView()
    
    /// Contains auxiliary subviews.
    fileprivate var miscContainerView = UIView()
    
    fileprivate var animator: UIDynamicAnimator!
    
    fileprivate var viewManagers = [UIView: ViewManager]()
    
    fileprivate var scheduler = Scheduler()
    
    // MARK: Life cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        addSubview(containerView)
        addSubview(miscContainerView)
        animator = UIDynamicAnimator(referenceView: self)
    }
    
    deinit {
        nextView = nil
        
        didStart = nil
        swiping = nil
        didEnd = nil
        didSwipe = nil
        didCancel = nil
        didDisappear = nil
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
    }
    
    // MARK: Public APIs
    open func topView() -> UIView? {
        return activeViews().first
    }
    
    // top view first
    open func activeViews() -> [UIView] {
        return allViews().filter() {
            view in
            guard let viewManager = viewManagers[view] else { return false }
            if case .swiping(_) = viewManager.state {
                return false
            }
            return true
            }.reversed()
    }
    
    open func loadViews() {
        for _ in UInt(activeViews().count) ..< numberOfActiveView {
            if let nextView = nextView?() {
                insert(nextView, atIndex: 0)
            }
        }
        updateViews()
    }
    
    open func rewind() {
        var viewToBeRewinded: UIView?
        if let lastSwipedView = history.popLast() {
            viewToBeRewinded = lastSwipedView
        } else if let view = previousView?() {
            viewToBeRewinded = view
        }
        
        guard let view = viewToBeRewinded else { return }
        
        insert(view, atIndex: allViews().count)
        updateViews()
    }
    
    open func discardViews() {
        for view in allViews() {
            remove(view)
        }
    }
    
    open func swipeTopView(inDirection direction: Direction) {
        guard let topView = topView() else { return }
        let (location, directionVector) = interpretDirection(topView, direction, activeViews(), self)
        swipeTopView(fromPoint: location, inDirection: directionVector)
    }
    
    open func swipeTopView(fromPoint location: CGPoint, inDirection directionVector: CGVector) {
        guard let topView = topView(), let topViewManager = viewManagers[topView] else { return }
        topViewManager.state = .swiping(location, directionVector)
        swipeView(topView, location: location, directionVector: directionVector)
    }
    
    // MARK: Private APIs
    fileprivate func allViews() -> [UIView] {
        return containerView.subviews
    }
    
    fileprivate func insert(_ view: UIView, atIndex index: Int) {
        guard !allViews().contains(view) else {
            // this view has been schedule to be removed
            guard let viewManager = viewManagers[view] else { return }
            viewManager.state = viewManager.snappingStateAtContainerCenter()
            return
        }
        
        let viewManager = ViewManager(view: view, containerView: containerView, index: index, miscContainerView: miscContainerView, animator: animator, swipeableView: self)
        viewManagers[view] = viewManager
    }
    
    fileprivate func remove(_ view: UIView) {
        guard allViews().contains(view) else { return }
        
        viewManagers.removeValue(forKey: view)
        self.didDisappear?(view)
    }
    
    open func updateViews() {
        let activeViews = self.activeViews()
        let inactiveViews = allViews().arrayByRemoveObjectsInArray(activeViews)
        
        for view in inactiveViews {
            view.isUserInteractionEnabled = false
        }
        
        guard let gestureRecognizers = activeViews.first?.gestureRecognizers , gestureRecognizers.filter({ gestureRecognizer in gestureRecognizer.state != .possible }).count == 0 else { return }
        
        for i in 0 ..< activeViews.count {
            let view = activeViews[i]
            view.isUserInteractionEnabled = onlySwipeTopCard ? i == 0 : true
            let shouldBeHidden = i >= Int(numberOfActiveView)
            view.isHidden = shouldBeHidden
            guard !shouldBeHidden else { continue }
            animateView(view, i, activeViews, self)
        }
    }
    
    func swipeView(_ view: UIView, location: CGPoint, directionVector: CGVector) {
        let direction = Direction.fromPoint(CGPoint(x: directionVector.dx, y: directionVector.dy))
        
        scheduleToBeRemoved(view) { aView in
            !self.containerView.convert(aView.frame, to: nil).intersects(UIScreen.main.bounds)
        }
        didSwipe?(view, direction, directionVector)
        loadViews()
    }
    
    func scheduleToBeRemoved(_ view: UIView, withPredicate predicate: @escaping (UIView) -> Bool) {
        guard allViews().contains(view) else { return }
        
        history.append(view)
        if UInt(history.count) > numberOfHistoryItem {
            history.removeFirst()
        }
        scheduler.scheduleRepeatedly({ () -> Void in
            self.allViews().arrayByRemoveObjectsInArray(self.activeViews()).filter({ view in predicate(view) }).forEach({ view in self.remove(view) })
        }, interval: 0.3) { () -> Bool in
            return self.activeViews().count == self.allViews().count
        }
    }
    
}

// MARK: - Default behaviors
extension ZLSwipeableView {
    
    static func defaultAnimateViewHandler() -> AnimateViewHandler {
        func toRadian(_ degree: CGFloat) -> CGFloat {
            return degree * CGFloat(M_PI / 180)
        }
        
        func rotateView(_ view: UIView, forDegree degree: CGFloat, duration: TimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView,  completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                view.center = swipeableView.convert(swipeableView.center, from: swipeableView.superview)
                var transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                transform = transform.rotated(by: toRadian(degree))
                transform = transform.translatedBy(x: -offset.x, y: -offset.y)
                view.transform = transform
            },
                           completion: completion)
        }
        
        return { (view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            let degree = CGFloat(1)
            let duration = 0.4
            let offset = CGPoint(x: 0, y: swipeableView.bounds.height * 0.3)
            switch index {
            case 0:
                rotateView(view, forDegree: 0, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            case 1:
                rotateView(view, forDegree: degree, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            case 2:
                rotateView(view, forDegree: -degree, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            default:
                rotateView(view, forDegree: 0, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            }
        }
    }
    
    static func defaultInterpretDirectionHandler() -> InterpretDirectionHandler {
        return { (topView: UIView, direction: Direction, views: [UIView], swipeableView: ZLSwipeableView) in
            let programmaticSwipeVelocity = CGFloat(1000)
            let location = CGPoint(x: topView.center.x, y: topView.center.y*0.7)
            var directionVector: CGVector!
            
            switch direction {
            case Direction.Left:
                directionVector = CGVector(dx: -programmaticSwipeVelocity, dy: 0)
            case Direction.Right:
                directionVector = CGVector(dx: programmaticSwipeVelocity, dy: 0)
            case Direction.Up:
                directionVector = CGVector(dx: 0, dy: -programmaticSwipeVelocity)
            case Direction.Down:
                directionVector = CGVector(dx: 0, dy: programmaticSwipeVelocity)
            default:
                directionVector = CGVector(dx: 0, dy: 0)
            }
            
            return (location, directionVector)
        }
    }
    
    static func defaultShouldSwipeViewHandler() -> ShouldSwipeHandler {
        return { (view: UIView, movement: Movement, swipeableView: ZLSwipeableView) -> Bool in
            let translation = movement.translation
            let velocity = movement.velocity
            let bounds = swipeableView.bounds
            let minTranslationInPercent = swipeableView.minTranslationInPercent
            let minVelocityInPointPerSecond = swipeableView.minVelocityInPointPerSecond
            let allowedDirection = swipeableView.allowedDirection
            
            func areTranslationAndVelocityInTheSameDirection() -> Bool {
                return CGPoint.areInSameTheDirection(translation, p2: velocity)
            }
            
            func isDirectionAllowed() -> Bool {
                return Direction.fromPoint(translation).intersection(allowedDirection) != .None
            }
            
            func isTranslationLargeEnough() -> Bool {
                return abs(translation.x) > minTranslationInPercent * bounds.width || abs(translation.y) > minTranslationInPercent * bounds.height
            }
            
            func isVelocityLargeEnough() -> Bool {
                return velocity.magnitude > minVelocityInPointPerSecond
            }
            
            return isDirectionAllowed() && areTranslationAndVelocityInTheSameDirection() && (isTranslationLargeEnough() || isVelocityLargeEnough())
        }
    }
    
}

// MARK: - Deprecated APIs
extension ZLSwipeableView {
    
    @available(*, deprecated: 1, message: "Use numberOfActiveView")
    public var numPrefetchedViews: UInt {
        get {
            return numberOfActiveView
        }
        set(newValue){
            numberOfActiveView = newValue
        }
    }
    
    @available(*, deprecated: 1, message: "Use allowedDirection")
    public var direction: Direction {
        get {
            return allowedDirection
        }
        set(newValue){
            allowedDirection = newValue
        }
    }
    
    @available(*, deprecated: 1, message: "Use minTranslationInPercent")
    public var translationThreshold: CGFloat {
        get {
            return minTranslationInPercent
        }
        set(newValue){
            minTranslationInPercent = newValue
        }
    }
    
    @available(*, deprecated: 1, message: "Use minVelocityInPointPerSecond")
    public var velocityThreshold: CGFloat {
        get {
            return minVelocityInPointPerSecond
        }
        set(newValue){
            minVelocityInPointPerSecond = newValue
        }
    }
    
}

// MARK: - Helper extensions
public func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

extension CGPoint {
    
    init(vector: CGVector) {
        self.init(x: vector.dx, y: vector.dy)
    }
    
    var normalized: CGPoint {
        return CGPoint(x: x / magnitude, y: y / magnitude)
    }
    
    var magnitude: CGFloat {
        return CGFloat(sqrtf(powf(Float(x), 2) + powf(Float(y), 2)))
    }
    
    static func areInSameTheDirection(_ p1: CGPoint, p2: CGPoint) -> Bool {
        
        func signNum(_ n: CGFloat) -> Int {
            return (n < 0.0) ? -1 : (n > 0.0) ? +1 : 0
        }
        
        return signNum(p1.x) == signNum(p2.x) && signNum(p1.y) == signNum(p2.y)
    }
    
}

extension CGVector {
    
    init(point: CGPoint) {
        self.init(dx: point.x, dy: point.y)
    }
    
}

extension Array where Element: Equatable {
    
    func arrayByRemoveObjectsInArray(_ array: [Element]) -> [Element] {
        return Array(self).filter() { element in !array.contains(element) }
    }
    
}


class ViewManager : NSObject {
    
    // Snapping -> [Moving]+ -> Snapping
    // Snapping -> [Moving]+ -> Swiping -> Snapping
    enum State {
        case snapping(CGPoint), moving(CGPoint), swiping(CGPoint, CGVector)
    }
    
    var state: State {
        didSet {
            if case .snapping(_) = oldValue,  case let .moving(point) = state {
                unsnapView()
                attachView(toPoint: point)
            } else if case .snapping(_) = oldValue,  case let .swiping(origin, direction) = state {
                unsnapView()
                attachView(toPoint: origin)
                pushView(fromPoint: origin, inDirection: direction)
            } else if case .moving(_) = oldValue, case let .moving(point) = state {
                moveView(toPoint: point)
            } else if case .moving(_) = oldValue, case let .snapping(point) = state {
                detachView()
                snapView(point)
            } else if case .moving(_) = oldValue, case let .swiping(origin, direction) = state {
                pushView(fromPoint: origin, inDirection: direction)
            } else if case .swiping(_, _) = oldValue, case let .snapping(point) = state {
                unpushView()
                detachView()
                snapView(point)
            }
        }
    }
    
    /// To be added to view and removed
    fileprivate class ZLPanGestureRecognizer: UIPanGestureRecognizer { }
    fileprivate class ZLTapGestureRecognizer: UITapGestureRecognizer { }
    
    static fileprivate let anchorViewWidth = CGFloat(1000)
    fileprivate var anchorView = UIView(frame: CGRect(x: 0, y: 0, width: anchorViewWidth, height: anchorViewWidth))
    
    fileprivate var snapBehavior: UISnapBehavior!
    fileprivate var viewToAnchorViewAttachmentBehavior: UIAttachmentBehavior!
    fileprivate var anchorViewToPointAttachmentBehavior: UIAttachmentBehavior!
    fileprivate var pushBehavior: UIPushBehavior!
    
    fileprivate let view: UIView
    fileprivate let containerView: UIView
    fileprivate let miscContainerView: UIView
    fileprivate let animator: UIDynamicAnimator
    fileprivate weak var swipeableView: ZLSwipeableView?
    
    init(view: UIView, containerView: UIView, index: Int, miscContainerView: UIView, animator: UIDynamicAnimator, swipeableView: ZLSwipeableView) {
        self.view = view
        self.containerView = containerView
        self.miscContainerView = miscContainerView
        self.animator = animator
        self.swipeableView = swipeableView
        self.state = ViewManager.defaultSnappingState(view)
        
        super.init()
        
        view.addGestureRecognizer(ZLPanGestureRecognizer(target: self, action: #selector(ViewManager.handlePan(_:))))
        view.addGestureRecognizer(ZLTapGestureRecognizer(target: self, action: #selector(ViewManager.handleTap(_:))))
        miscContainerView.addSubview(anchorView)
        containerView.insertSubview(view, at: index)
    }
    
    static func defaultSnappingState(_ view: UIView) -> State {
        return .snapping(view.convert(view.center, from: view.superview))
    }
    
    func snappingStateAtContainerCenter() -> State {
        guard let swipeableView = swipeableView else { return ViewManager.defaultSnappingState(view) }
        return .snapping(containerView.convert(swipeableView.center, from: swipeableView.superview))
    }
    
    deinit {
        if let snapBehavior = snapBehavior {
            removeBehavior(snapBehavior)
        }
        if let viewToAnchorViewAttachmentBehavior = viewToAnchorViewAttachmentBehavior {
            removeBehavior(viewToAnchorViewAttachmentBehavior)
        }
        if let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior {
            removeBehavior(anchorViewToPointAttachmentBehavior)
        }
        if let pushBehavior = pushBehavior {
            removeBehavior(pushBehavior)
        }
        
        for gestureRecognizer in view.gestureRecognizers! {
            if gestureRecognizer is  ZLPanGestureRecognizer {
                view.removeGestureRecognizer(gestureRecognizer)
            }
        }
        
        anchorView.removeFromSuperview()
        view.removeFromSuperview()
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let swipeableView = swipeableView else { return }
        
        let translation = recognizer.translation(in: containerView)
        let location = recognizer.location(in: containerView)
        let velocity = recognizer.velocity(in: containerView)
        let movement = Movement(location: location, translation: translation, velocity: velocity)
        
        switch recognizer.state {
        case .began:
            guard case .snapping(_) = state else { return }
            state = .moving(location)
            swipeableView.didStart?(view, location)
        case .changed:
            guard case .moving(_) = state else { return }
            state = .moving(location)
            swipeableView.swiping?(view, location, translation)
        case .ended, .cancelled:
            guard case .moving(_) = state else { return }
            if swipeableView.shouldSwipeView(view, movement, swipeableView) {
                let directionVector = CGVector(point: translation.normalized * max(velocity.magnitude, swipeableView.minVelocityInPointPerSecond))
                state = .swiping(location, directionVector)
                swipeableView.swipeView(view, location: location, directionVector: directionVector)
            } else {
                state = snappingStateAtContainerCenter()
                swipeableView.didCancel?(view)
            }
            swipeableView.didEnd?(view, location)
        default:
            break
        }
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let swipeableView = swipeableView, let topView = swipeableView.topView()  else { return }
        
        let location = recognizer.location(in: containerView)
        swipeableView.didTap?(topView, location)
    }
    
    fileprivate func snapView(_ point: CGPoint) {
        snapBehavior = UISnapBehavior(item: view, snapTo: point)
        snapBehavior!.damping = 0.75
        addBehavior(snapBehavior)
    }
    
    fileprivate func unsnapView() {
        guard let snapBehavior = snapBehavior else { return }
        removeBehavior(snapBehavior)
    }
    
    fileprivate func attachView(toPoint point: CGPoint) {
        anchorView.center = point
        anchorView.backgroundColor = APP_THEME_COLOR
        anchorView.isHidden = true
        
        // attach aView to anchorView
        let p = view.center
        viewToAnchorViewAttachmentBehavior = UIAttachmentBehavior(item: view, offsetFromCenter: UIOffset(horizontal: -(p.x - point.x), vertical: -(p.y - point.y)), attachedTo: anchorView, offsetFromCenter: UIOffset.zero)
        viewToAnchorViewAttachmentBehavior!.length = 0
        
        // attach anchorView to point
        anchorViewToPointAttachmentBehavior = UIAttachmentBehavior(item: anchorView, offsetFromCenter: UIOffset.zero, attachedToAnchor: point)
        anchorViewToPointAttachmentBehavior!.damping = 100
        anchorViewToPointAttachmentBehavior!.length = 0
        
        addBehavior(viewToAnchorViewAttachmentBehavior!)
        addBehavior(anchorViewToPointAttachmentBehavior!)
    }
    
    fileprivate func moveView(toPoint point: CGPoint) {
        guard let _ = viewToAnchorViewAttachmentBehavior, let toPoint = anchorViewToPointAttachmentBehavior else { return }
        toPoint.anchorPoint = point
    }
    
    fileprivate func detachView() {
        guard let viewToAnchorViewAttachmentBehavior = viewToAnchorViewAttachmentBehavior, let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior else { return }
        removeBehavior(viewToAnchorViewAttachmentBehavior)
        removeBehavior(anchorViewToPointAttachmentBehavior)
    }
    
    fileprivate func pushView(fromPoint point: CGPoint, inDirection direction: CGVector) {
        guard let _ = viewToAnchorViewAttachmentBehavior, let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior  else { return }
        
        removeBehavior(anchorViewToPointAttachmentBehavior)
        
        pushBehavior = UIPushBehavior(items: [anchorView], mode: .instantaneous)
        pushBehavior.pushDirection = direction
        addBehavior(pushBehavior)
    }
    
    fileprivate func unpushView() {
        guard let pushBehavior = pushBehavior else { return }
        removeBehavior(pushBehavior)
    }
    
    fileprivate func addBehavior(_ behavior: UIDynamicBehavior) {
        animator.addBehavior(behavior)
    }
    
    fileprivate func removeBehavior(_ behavior: UIDynamicBehavior) {
        animator.removeBehavior(behavior)
    }
    
}



class Scheduler : NSObject {
    
    typealias Action = () -> Void
    typealias EndCondition = () -> Bool
    
    var timer: Timer?
    var action: Action?
    var endCondition: EndCondition?
    
    func scheduleRepeatedly(_ action: @escaping Action, interval: TimeInterval, endCondition: @escaping EndCondition)  {
        guard timer == nil && interval > 0 else { return }
        self.action = action
        self.endCondition = endCondition
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(Scheduler.doAction(_:)), userInfo: nil, repeats: true)
    }
    
    func doAction(_ timer: Timer) {
        guard let action = action, let endCondition = endCondition , !endCondition() else {
            timer.invalidate()
            self.timer = nil
            self.action = nil
            self.endCondition = nil
            return
        }
        action()
    }
    
}

public typealias ZLSwipeableViewDirection = Direction

extension Direction: Equatable {}
public func ==(lhs: Direction, rhs: Direction) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

/**
 *  Swiped direction.
 */
public struct Direction : OptionSet, CustomStringConvertible {
    
    public var rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let None = Direction(rawValue: 0b0000)
    public static let Left = Direction(rawValue: 0b0001)
    public static let Right = Direction(rawValue: 0b0010)
    public static let Up = Direction(rawValue: 0b0100)
    public static let Down = Direction(rawValue: 0b1000)
    public static let Horizontal: Direction = [Left, Right]
    public static let Vertical: Direction = [Up, Down]
    public static let All: Direction = [Horizontal, Vertical]
    
    public static func fromPoint(_ point: CGPoint) -> Direction {
        switch (point.x, point.y) {
        case let (x, y) where abs(x) >= abs(y) && x > 0:
            return .Right
        case let (x, y) where abs(x) >= abs(y) && x < 0:
            return .Left
        case let (x, y) where abs(x) < abs(y) && y < 0:
            return .Up
        case let (x, y) where abs(x) < abs(y) && y > 0:
            return .Down
        case (_, _):
            return .None
        }
    }
    
    public var description: String {
        switch self {
        case Direction.None:
            return "None"
        case Direction.Left:
            return "Left"
        case Direction.Right:
            return "Right"
        case Direction.Up:
            return "Up"
        case Direction.Down:
            return "Down"
        case Direction.Horizontal:
            return "Horizontal"
        case Direction.Vertical:
            return "Vertical"
        case Direction.All:
            return "All"
        default:
            return "Unknown"
        }
    }
    
}


extension Date {
    /// The year.
    
    /// The second.
    public var second: Int {
        return dateComponents.second!
    }
    
    /// The nanosecond.
    public var nanosecond: Int {
        return dateComponents.nanosecond!
    }
        
    fileprivate var dateComponents: DateComponents {
        return calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday], from: self)
    }
    
    /// Creates a new instance with specified date components.
    ///
    /// - parameter era:        The era.
    /// - parameter year:       The year.
    /// - parameter month:      The month.
    /// - parameter day:        The day.
    /// - parameter hour:       The hour.
    /// - parameter minute:     The minute.
    /// - parameter second:     The second.
    /// - parameter nanosecond: The nanosecond.
    /// - parameter calendar:   The calendar used to create a new instance.
    ///
    /// - returns: The created `Date` instance.
    public init(era: Int?, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Int, on calendar: Calendar) {
        let now = Date()
        var dateComponents = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .nanosecond], from: now)
        dateComponents.era = era
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        dateComponents.nanosecond = nanosecond
        
        let date = calendar.date(from: dateComponents)
        self.init(timeInterval: 0, since: date!)
    }
    
    /// Creates a new instance with specified date componentns.
    ///
    /// - parameter year:       The year.
    /// - parameter month:      The month.
    /// - parameter day:        The day.
    /// - parameter hour:       The hour.
    /// - parameter minute:     The minute.
    /// - parameter second:     The second.
    /// - parameter nanosecond: The nanosecond. `0` by default.
    ///
    /// - returns: The created `Date` instance.
    public init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Int = 0) {
        self.init(era: nil, year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond, on: .current)
    }
    
    /// Creates a new Instance with specified date components
    ///
    /// - parameter year:  The year.
    /// - parameter month: The month.
    /// - parameter day:   The day.
    ///
    /// - returns: The created `Date` instance.
    public init(year: Int, month: Int, day: Int) {
        self.init(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
    }
    
    /// Creates a new instance added a `DateComponents`
    ///
    /// - parameter left:  The date.
    /// - parameter right: The date components.
    ///
    /// - returns: The created `Date` instance.
    public static func + (left: Date, right: DateComponents) -> Date? {
        return Calendar.current.date(byAdding: right, to: left)
    }
    
    /// Creates a new instance subtracted a `DateComponents`
    ///
    /// - parameter left:  The date.
    /// - parameter right: The date components.
    ///
    /// - returns: The created `Date` instance.
    public static func - (left: Date, right: DateComponents) -> Date? {
        return Calendar.current.date(byAdding: -right, to: left)
    }
    
    /// Creates a new `String` instance representing the receiver formatted in given date style and time style.
    ///
    /// - parameter dateStyle: The date style.
    /// - parameter timeStyle: The time style.
    ///
    /// - returns: The created `String` instance.
    public func string(inDateStyle dateStyle: DateFormatter.Style, andTimeStyle timeStyle: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        
        return dateFormatter.string(from: self)
    }
    
    /// Creates a new `String` instance representing the date of the receiver formatted in given date style.
    ///
    /// - parameter dateStyle: The date style.
    ///
    /// - returns: The created `String` instance.
    public func dateString(in dateStyle: DateFormatter.Style) -> String {
        return string(inDateStyle: dateStyle, andTimeStyle: .none)
    }
    
    /// Creates a new `String` instance representing the time of the receiver formatted in given time style.
    ///
    /// - parameter timeStyle: The time style.
    ///
    /// - returns: The created `String` instance.
    public func timeString(in timeStyle: DateFormatter.Style) -> String {
        return string(inDateStyle: .none, andTimeStyle: timeStyle)
    }
}

public extension DateComponents {
    var ago: Date? {
        return Calendar.current.date(byAdding: -self, to: Date())
    }
    
    var later: Date? {
        return Calendar.current.date(byAdding: self, to: Date())
    }
    
    /// Creates inverse `DateComponents`
    ///
    /// - parameter rhs: A `DateComponents`
    ///
    /// - returns: A created inverse `DateComponents`
    static prefix func -(rhs: DateComponents) -> DateComponents {
        var dateComponents = DateComponents()
        
        if let year = rhs.year {
            dateComponents.year = -year
        }
        
        if let month = rhs.month {
            dateComponents.month = -month
        }
        
        if let day = rhs.day {
            dateComponents.day = -day
        }
        
        if let hour = rhs.hour {
            dateComponents.hour = -hour
        }
        
        if let minute = rhs.minute {
            dateComponents.minute = -minute
        }
        
        if let second = rhs.second {
            dateComponents.second = -second
        }
        
        if let nanosecond = rhs.nanosecond {
            dateComponents.nanosecond = -nanosecond
        }
        
        return dateComponents
    }
    
    /// Creates a instance calculated by the addition of `right` and `left`
    ///
    /// - parameter left:  The date components at left side.
    /// - parameter right: The date components at right side.
    ///
    /// - returns: Created `DateComponents` instance.
    static func + (left: DateComponents, right: DateComponents) -> DateComponents {
        var dateComponents = left
        
        if let year = right.year {
            dateComponents.year = (dateComponents.year ?? 0) + year
        }
        
        if let month = right.month {
            dateComponents.month = (dateComponents.month ?? 0) + month
        }
        
        if let day = right.day {
            dateComponents.day = (dateComponents.day ?? 0) + day
        }
        
        if let hour = right.hour {
            dateComponents.hour = (dateComponents.hour ?? 0) + hour
        }
        
        if let minute = right.minute {
            dateComponents.minute = (dateComponents.minute ?? 0) + minute
        }
        
        if let second = right.second {
            dateComponents.second = (dateComponents.second ?? 0) + second
        }
        
        if let nanosecond = right.nanosecond {
            dateComponents.nanosecond = (dateComponents.nanosecond ?? 0) + nanosecond
        }
        
        return dateComponents
    }
    
    /// Creates a instance calculated by the subtraction from `right` to `left`
    ///
    /// - parameter left:  The date components at left side.
    /// - parameter right: The date components at right side.
    ///
    /// - returns: Created `DateComponents` instance.
    static func - (left: DateComponents, right: DateComponents) -> DateComponents {
        return left + (-right)
    }
    
    /// Creates a `String` instance representing the receiver formatted in given units style.
    ///
    /// - parameter unitsStyle: The units style.
    ///
    /// - returns: The created a `String` instance.
    @available(OSX 10.10, *)
    public func string(in unitsStyle: DateComponentsFormatter.UnitsStyle) -> String? {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = unitsStyle
        dateComponentsFormatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second, .nanosecond]
        
        return dateComponentsFormatter.string(from: self)
    }
}

// MARK: - Hokusai

private struct HOKConsts {
    let animationDuration:TimeInterval = 0.8
    let hokusaiTag = 9999
}

// Action Types
public enum HOKAcitonType {
    case none, selector, closure
}

// Color Types
public enum HOKColorScheme {
    case hokusai, asagi, matcha, tsubaki, inari, karasu, enshu
    
    func getColors() -> HOKColors {
        switch self {
        case .asagi:
            return HOKColors(
                backGroundColor: UIColorHex(0x0bada8),
                buttonColor: UIColorHex(0x08827e),
                cancelButtonColor: UIColorHex(0x6dcecb),
                fontColor: UIColorHex(0xffffff)
            )
        case .matcha:
            return HOKColors(
                backGroundColor: UIColorHex(0x314631),
                buttonColor: UIColorHex(0x618c61),
                cancelButtonColor: UIColorHex(0x496949),
                fontColor: UIColorHex(0xffffff)
            )
        case .tsubaki:
            return HOKColors(
                backGroundColor: UIColorHex(0xe5384c),
                buttonColor: UIColorHex(0xac2a39),
                cancelButtonColor: UIColorHex(0xc75764),
                fontColor: UIColorHex(0xffffff)
            )
        case .inari:
            return HOKColors(
                backGroundColor: UIColorHex(0xdd4d05),
                buttonColor: UIColorHex(0xa63a04),
                cancelButtonColor: UIColorHex(0xb24312),
                fontColor: UIColorHex(0x231e1c)
            )
        case .karasu:
            return HOKColors(
                backGroundColor: UIColorHex(0x180614),
                buttonColor: UIColorHex(0x3d303d),
                cancelButtonColor: UIColorHex(0x261d26),
                fontColor: UIColorHex(0x9b9981)
            )
        case .enshu:
            return HOKColors(
                backGroundColor: UIColorHex(0xccccbe),
                buttonColor: UIColorHex(0xffffff),
                cancelButtonColor: UIColorHex(0xe5e5d8),
                fontColor: UIColorHex(0x9b9981)
            )
        default: // Hokusai
            return HOKColors(
                backGroundColor: UIColorHex(0x6F146F),
                buttonColor: UIColorHex(0xA976AB),
                cancelButtonColor: UIColorHex(0x8C458D),
                fontColor: UIColorHex(0xffffff)
            )
        }
    }
    
    fileprivate func UIColorHex(_ hex: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

final public class HOKColors: NSObject {
    var backgroundColor: UIColor
    var buttonColor: UIColor
    var cancelButtonColor: UIColor
    var fontColor: UIColor
    
    required public init(backGroundColor: UIColor, buttonColor: UIColor, cancelButtonColor: UIColor, fontColor: UIColor) {
        self.backgroundColor   = backGroundColor
        self.buttonColor       = buttonColor
        self.cancelButtonColor = cancelButtonColor
        self.fontColor         = fontColor
    }
}

final public class HOKButton: UIButton {
    var target:AnyObject!
    var selector:Selector!
    var action:(()->Void)!
    var actionType = HOKAcitonType.none
    var isCancelButton = false
    
    // Font
    let kDefaultFont      = "SFUIText-Medium"
    let kFontSize:CGFloat = 16.0
    
    func setColor(_ colors: HOKColors) {
        self.setTitleColor(colors.fontColor, for: UIControlState())
        self.backgroundColor = (isCancelButton) ? colors.cancelButtonColor : colors.buttonColor
    }
    
    func setFontName(_ fontName: String?) {
        let name:String
        if let fontName = fontName, !fontName.isEmpty {
            name = fontName
        } else {
            name = kDefaultFont
        }
        self.titleLabel?.font = UIFont(name: name, size:kFontSize)
    }
}

final public class HOKLabel: UILabel {
    var isTitle = true
    
    // Font
    var kDefaultFont:String {
        return isTitle ? "AvenirNext-DemiBold" : "AvenirNext-Light"
    }
    let kFontSize:CGFloat = 16.0
    
    func setColor(_ colors: HOKColors) {
        self.textColor = colors.fontColor
        self.backgroundColor = UIColor.clear
    }
    
    func setFontName(_ fontName: String?) {
        let name:String
        if let fontName = fontName, !fontName.isEmpty {
            name = fontName
        } else {
            name = kDefaultFont
        }
        self.font = UIFont(name: name, size:kFontSize)
    }
}

final public class HOKMenuView: UIView {
    var colorScheme = HOKColorScheme.hokusai
    
    public let kDamping: CGFloat               = 0.7
    public let kInitialSpringVelocity: CGFloat = 0.8
    
    fileprivate var displayLink: CADisplayLink?
    fileprivate let shapeLayer     = CAShapeLayer()
    fileprivate var bendableOffset = UIOffset.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setShapeLayer(_ colors: HOKColors) {
        self.backgroundColor = UIColor.clear
        shapeLayer.fillColor = colors.backgroundColor.darkerColorWithPercentage(0.5).cgColor
        shapeLayer.frame     = frame
        self.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    func positionAnimationWillStart() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(HOKMenuView.tick(_:)))
            displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
        shapeLayer.frame = CGRect(origin: CGPoint.zero, size: frame.size)
    }
    
    func updatePath() {
        let width  = shapeLayer.bounds.width
        let height = shapeLayer.bounds.height
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(to: CGPoint(x: width, y: 0),
                          controlPoint:CGPoint(x: width * 0.5, y: 0 + bendableOffset.vertical))
        path.addQuadCurve(to: CGPoint(x: width, y: height + 100.0),
                          controlPoint:CGPoint(x: width + bendableOffset.horizontal, y: height * 0.5))
        path.addQuadCurve(to: CGPoint(x: 0, y: height + 100.0),
                          controlPoint: CGPoint(x: width * 0.5, y: height + 100.0))
        path.addQuadCurve(to: CGPoint(x: 0, y: 0),
                          controlPoint: CGPoint(x: bendableOffset.horizontal, y: height * 0.5))
        path.close()
        
        shapeLayer.path = path.cgPath
    }
    
    func tick(_ displayLink: CADisplayLink) {
        if layer.presentation() != nil {
            var verticalOffset = self.layer.frame.origin.y - layer.presentation()!.frame.origin.y
            
            // On dismissing, the offset should not be offended on the buttons.
            if verticalOffset > 0 {
                verticalOffset *= 0.2
            }
            
            bendableOffset = UIOffset(
                horizontal: 0.0,
                vertical: verticalOffset
            )
            updatePath()
            
            if verticalOffset == 0 {
                self.displayLink!.invalidate()
                self.displayLink = nil
            }
        }
    }
}

final public class Hokusai: UIViewController, UIGestureRecognizerDelegate {
    // Views
    fileprivate var menuView   = HOKMenuView()
    fileprivate var buttons    = [HOKButton]()
    fileprivate var labels     = [HOKLabel]()
    
    fileprivate var instance:Hokusai!        = nil
    fileprivate var kButtonWidth:CGFloat     = 250
    fileprivate let kButtonHeight:CGFloat    = 48.0
    fileprivate let kElementInterval:CGFloat = 16.0
    fileprivate var kLabelWidth:CGFloat { return kButtonWidth }
    fileprivate let kLabelHeight:CGFloat     = 30.0
    fileprivate var bgColor                  = UIColor(white: 1.0, alpha: 0.7)
    
    // Variables users can change
    public var colorScheme        = HOKColorScheme.hokusai
    public var fontName           = ""
    public var lightFontName      = ""
    public var colors:HOKColors!  = nil
    public var cancelButtonTitle  = "Cancel"
    public var cancelButtonAction : (()->Void)?
    public var headline: String   = ""
    public var message:String     = ""
    
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    required public init() {
        super.init(nibName:nil, bundle:nil)
        view.frame            = UIScreen.main.bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        view.backgroundColor  = UIColor.clear
        
        menuView.frame = view.frame
        view.addSubview(menuView)
        
        kButtonWidth = view.frame.width * 0.8
        
        // Gesture Recognizer for outside the menu
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismiss")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(Hokusai.onOrientationChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    /// Convenience initializer to allow a title and optional message
    convenience public init(headline: String, message: String = "") {
        self.init()
        self.headline = headline
        self.message  = message
    }
    
    func onOrientationChange(_ notification: Notification) {
        self.updateFrames()
        self.view.layoutIfNeeded()
    }
    
    func updateFrames() {
        kButtonWidth = view.frame.width * 0.8
        
        var yPrevious:CGFloat = 0
        for label in labels {
            label.frame  = CGRect(x: 0.0, y: 0.0, width: kLabelWidth, height: kLabelHeight)
            label.sizeToFit()
            label.center = CGPoint(x: view.center.x, y: label.frame.size.height * 0.5 + yPrevious + kElementInterval)
            yPrevious = label.frame.maxY
        }
        
        for btn in buttons {
            btn.frame  = CGRect(x: 0.0, y: 0.0, width: kButtonWidth, height: kButtonHeight)
            btn.center = CGPoint(x: view.center.x, y: kButtonHeight * 0.5 + yPrevious + kElementInterval)
            yPrevious = btn.frame.maxY
        }
        
        let labelHeights = labels.flatMap { $0.frame.height }.reduce(0, +)
        let buttonHeights = buttons.flatMap { $0.frame.height }.reduce(0, +)
        let menuHeight = CGFloat(buttons.count + labels.count + 1) * kElementInterval + labelHeights + buttonHeights
        menuView.frame = CGRect(
            x: 0,
            y: view.frame.height - menuHeight,
            width: view.frame.width,
            height: menuHeight
        )
        
        menuView.shapeLayer.frame = CGRect(origin: CGPoint.zero, size: menuView.frame.size)
        menuView.updatePath()
        menuView.layoutIfNeeded()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != gestureRecognizer.view {
            return false
        }
        return true
    }
    
    // Add a button with a closure
    public func addButton(_ title:String, action:@escaping ()->Void) -> HOKButton {
        let btn        = addButton(title)
        btn.action     = action
        btn.actionType = HOKAcitonType.closure
        btn.addTarget(self, action:#selector(Hokusai.buttonTapped(_:)), for:.touchUpInside)
        return btn
    }
    
    // Add a button with a selector
    public func addButton(_ title:String, target:AnyObject, selector:Selector) -> HOKButton {
        let btn        = addButton(title)
        btn.target     = target
        btn.selector   = selector
        btn.actionType = HOKAcitonType.selector
        btn.addTarget(self, action:#selector(Hokusai.buttonTapped(_:)), for:.touchUpInside)
        btn.addTarget(self, action:#selector(Hokusai.buttonDarker(_:)), for:.touchDown)
        btn.addTarget(self, action:#selector(Hokusai.buttonLighter(_:)), for:.touchUpOutside)
        return btn
    }
    
    // Add a cancel button
    public func addCancelButton(_ title:String) -> HOKButton {
        if let cancelButtonAction = cancelButtonAction {
            let btn = addButton(title, action: cancelButtonAction)
            btn.isCancelButton = true
            return btn
        } else {
            let btn        = addButton(title)
            btn.addTarget(self, action:#selector(Hokusai.buttonTapped(_:)), for:.touchUpInside)
            btn.addTarget(self, action:#selector(Hokusai.buttonDarker(_:)), for:.touchDown)
            btn.addTarget(self, action:#selector(Hokusai.buttonLighter(_:)), for:.touchUpOutside)
            btn.isCancelButton = true
            return btn
        }
    }
    
    // Add a button just with a title
    fileprivate func addButton(_ title:String) -> HOKButton {
        let btn = HOKButton()
        btn.layer.masksToBounds = true
        btn.setTitle(title, for: UIControlState())
        menuView.addSubview(btn)
        buttons.append(btn)
        return btn
    }
    
    // Add a multi-lined message label
    fileprivate func addMessageLabel(_ text: String) -> HOKLabel {
        let label = addLabel(text)
        label.isTitle = false
        return label
    }
    
    // Add a multi-lined label just with a text
    fileprivate func addLabel(_ text: String) -> HOKLabel {
        let label = HOKLabel()
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.text = text
        label.numberOfLines = 0
        menuView.addSubview(label)
        labels.append(label)
        return label
    }
    
    // Show the menu
    public func show() {
        if let rv = UIApplication.shared.keyWindow {
            if rv.viewWithTag(HOKConsts().hokusaiTag) == nil {
                view.tag = HOKConsts().hokusaiTag.hashValue
                rv.addSubview(view)
            }
        } else {
            print("Hokusai::  You have to call show() after the controller has appeared.")
            return
        }
        
        // This is needed to retain this instance.
        instance = self
        
        let colors = (self.colors == nil) ? colorScheme.getColors() : self.colors
        
        // Set a background color of Menuview
        menuView.setShapeLayer(colors!)
        
        // Add a cancel button
        self.addCancelButton(cancelButtonTitle)
        
        // Add a title label when title is set
        if !headline.isEmpty {
            self.addLabel(headline)
        }
        
        // Add a message label when message is set
        if !message.isEmpty {
            self.addMessageLabel(message)
        }
        
        // Style buttons
        for btn in buttons {
            btn.layer.cornerRadius = kButtonHeight * 0.5
            btn.setFontName(fontName)
            btn.setColor(colors!)
        }
        
        // Style labels
        for label in labels {
            label.setFontName( label.isTitle ? fontName : lightFontName)
            label.setColor(colors!)
        }
        
        // Set frames
        self.updateFrames()
        
        // Animations
        animationWillStart()
        
        // Debug
        if (buttons.count == 0) {
            print("Hokusai::  The menu has no item yet.")
        } else if (buttons.count > 6) {
            print("Hokusai::  The menu has lots of items.")
        }
    }
    
    // Add an animation when showing the menu
    fileprivate func animationWillStart() {
        // Background
        self.view.backgroundColor = UIColor.clear
        UIView.animate(withDuration: HOKConsts().animationDuration * 0.4,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        self.view.backgroundColor = self.bgColor
        },
                       completion: nil
        )
        
        // Menuview
        menuView.frame = CGRect(origin: CGPoint(x: 0.0, y: self.view.frame.height), size: menuView.frame.size)
        UIView.animate(withDuration: HOKConsts().animationDuration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.6,
                       options: [.beginFromCurrentState, .allowUserInteraction, .overrideInheritedOptions],
                       animations: {
                        self.menuView.frame = CGRect(origin: CGPoint(x: 0.0, y: self.view.frame.height-self.menuView.frame.height), size: self.menuView.frame.size)
        },
                       completion: {(finished) in
        })
        
        menuView.positionAnimationWillStart()
    }
    
    // Dismiss the menuview
    public func dismiss() {
        // Background and Menuview
        UIView.animate(withDuration: HOKConsts().animationDuration,
                       delay: 0.0,
                       usingSpringWithDamping: 100.0,
                       initialSpringVelocity: 0.6,
                       options: [.beginFromCurrentState, .allowUserInteraction, .overrideInheritedOptions, .curveEaseOut],
                       animations: {
                        self.view.backgroundColor = UIColor.clear
                        self.menuView.frame       = CGRect(origin: CGPoint(x: 0.0, y: self.view.frame.height), size: self.menuView.frame.size)
        },
                       completion: {(finished) in
                        self.view.removeFromSuperview()
        })
        menuView.positionAnimationWillStart()
    }
    
    // When a button is tapped, this method is called.
    func buttonTapped(_ btn:HOKButton) {
        if btn.actionType == HOKAcitonType.closure {
            btn.action()
        } else if btn.actionType == HOKAcitonType.selector {
            let control = UIControl()
            control.sendAction(btn.selector, to:btn.target, for:nil)
        } else {
            if !btn.isCancelButton {
                print("Unknow action type for button")
            }
        }
        dismiss()
    }
    
    
    // Make the buttons darker when user tapping.
    func buttonDarker(_ btn:HOKButton) {
        btn.backgroundColor = btn.backgroundColor!.darkerColorWithPercentage(0.2)
    }
    
    // Make the buttons lighter when user release finger.
    func buttonLighter(_ btn:HOKButton) {
        btn.backgroundColor = btn.backgroundColor!.lighterColorWithPercentage(0.2)
    }
    
}

extension UIColor {
    
    func lighterColorWithPercentage(_ percent : Double) -> UIColor {
        return colorWithBrightness(CGFloat(1 + percent));
    }
    
    func darkerColorWithPercentage(_ percent : Double) -> UIColor {
        return colorWithBrightness(CGFloat(1 - percent));
    }
    
    func colorWithBrightness(_ factor: CGFloat) -> UIColor {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
        } else {
            return self;
        }
    }
}


class TFAlertView: NSObject, UIAlertViewDelegate {
    
    fileprivate var callBack : ((Int) -> (Void))?
    fileprivate var unmanaged : Unmanaged<NSObject>?
    var alert: UIAlertView
    
    /**
     - parameter cancelButtonTitle: cancelButtonTitle has index 0
     */
    init(title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle:[String], didClick closure:@escaping (_ buttonIndex:Int) -> Void) {
        alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle)
        super.init() // To set the delegate as self we need to call its super.init() first.
        alert.delegate = self
        
        //Add buttons from otherButtonTitle
        for (_, title) in otherButtonTitle.enumerated() {
            alert.addButton(withTitle: title)
        }
        
        self.callBack = closure
        self.unmanaged = Unmanaged.passRetained(self)
        
        alert.show()
    }
    
    internal func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if let action = self.callBack {
            action(buttonIndex)
        }
        self.unmanaged?.release()
    }
}

class AlertViewWithTextField: NSObject, UIAlertViewDelegate {
    
    // ios 7 support
    fileprivate var alertView: UIAlertView?
    fileprivate var closureOk: ((_ text: String?) -> Void)?
    fileprivate var closureCancel: (() -> Void)?
    fileprivate var unmanaged : Unmanaged<NSObject>?
    var alert: Any?
    var alertViewControllerTextField: UITextField?
    
    /**
     @note: cancelButtonTitle cancelButtonTitle has index 0
     */
    init(title: String?,  message: String?, showOver: UIViewController!, didClickOk closureOk:@escaping (_ text: String?) -> Void, didClickCancel closureCancel:@escaping () -> Void){
        super.init()
        self.closureOk = closureOk
        self.closureCancel = closureCancel
        // ios 8
        if #available(iOS 8.0, *) {
            alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: { [weak self] (action) -> Void in
                if let strongSelf = self {
                    closureOk(strongSelf.alertViewControllerTextField?.text)
                    strongSelf.unmanaged?.release()
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                closureCancel();
            }
            (alert! as AnyObject).addAction(ok)
            (alert! as AnyObject).addAction(cancel)
            (alert! as AnyObject).addTextField(configurationHandler: {[weak self] (textField) in
                if let strongSelf = self {
                    strongSelf.alertViewControllerTextField = textField
                    strongSelf.unmanaged?.release()
                }
            })
            showOver.present(alert! as! UIAlertController, animated: true, completion: nil)
            
        } else {
            let alertMessage = message == nil ? "" : message
            let alertTitle = title == nil ? "" : title
            alertView = UIAlertView(title: alertTitle!, message: alertMessage!, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Ok")
            alertView!.alertViewStyle = UIAlertViewStyle.plainTextInput
            alertView!.show()
            
        }
        self.unmanaged = Unmanaged.passRetained(self)
    }
    
    internal func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            if self.closureCancel != nil {
                self.closureCancel!()
            }
        }
        else {
            if self.closureOk != nil {
                self.closureOk!(alertView.textField(at: 0)?.text)
            }
        }
        self.unmanaged?.release()
    }
    
}


extension UIColor {
    convenience public init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    public struct MKColor {
        public static let Red = UIColor(hex: 0xF44336)
        public static let Pink = UIColor(hex: 0xE91E63)
        public static let Purple = UIColor(hex: 0x9C27B0)
        public static let DeepPurple = UIColor(hex: 0x67AB7)
        public static let Indigo = UIColor(hex: 0x3F51B5)
        public static let Blue = UIColor(hex: 0x2196F3)
        public static let LightBlue = UIColor(hex: 0x03A9F4)
        public static let Cyan = UIColor(hex: 0x00BCD4)
        public static let Teal = UIColor(hex: 0x009688)
        public static let Green = UIColor(hex: 0x4CAF50)
        public static let LightGreen = UIColor(hex: 0x8BC34A)
        public static let Lime = UIColor(hex: 0xCDDC39)
        public static let Yellow = UIColor(hex: 0xFFEB3B)
        public static let Amber = UIColor(hex: 0xFFC107)
        public static let Orange = UIColor(hex: 0xFF9800)
        public static let DeepOrange = UIColor(hex: 0xFF5722)
        public static let Brown = UIColor(hex: 0x795548)
        public static let Grey = UIColor(hex: 0x9E9E9E)
        public static let BlueGrey = UIColor(hex: 0x607D8B)
    }
}

public enum MKTimingFunction {
    case linear
    case easeIn
    case easeOut
    case custom(Float, Float, Float, Float)
    
    public var function: CAMediaTimingFunction {
        switch self {
        case .linear:
            return CAMediaTimingFunction(name: "linear")
        case .easeIn:
            return CAMediaTimingFunction(name: "easeIn")
        case .easeOut:
            return CAMediaTimingFunction(name: "easeOut")
        case .custom(let cpx1, let cpy1, let cpx2, let cpy2):
            return CAMediaTimingFunction(controlPoints: cpx1, cpy1, cpx2, cpy2)
        }
    }
}

public enum MKRippleLocation {
    case center
    case left
    case right
    case tapLocation
}

open class MKLayer {
    fileprivate var superLayer: CALayer!
    fileprivate let rippleLayer = CALayer()
    fileprivate let backgroundLayer = CALayer()
    fileprivate let maskLayer = CAShapeLayer()
    
    open var rippleLocation: MKRippleLocation = .tapLocation {
        didSet {
            let origin: CGPoint?
            let sw = superLayer.bounds.width
            let sh = superLayer.bounds.height
            
            switch rippleLocation {
            case .center:
                origin = CGPoint(x: sw/2, y: sh/2)
            case .left:
                origin = CGPoint(x: sw*0.25, y: sh/2)
            case .right:
                origin = CGPoint(x: sw*0.75, y: sh/2)
            default:
                origin = nil
            }
            if let origin = origin {
                setCircleLayerLocationAt(origin)
            }
        }
    }
    
    open var ripplePercent: Float = 0.9 {
        didSet {
            if ripplePercent > 0 {
                let sw = superLayer.bounds.width
                let sh = superLayer.bounds.height
                let circleSize = CGFloat(max(sw, sh)) * CGFloat(ripplePercent)
                let circleCornerRadius = circleSize/2
                
                rippleLayer.cornerRadius = circleCornerRadius
                setCircleLayerLocationAt(CGPoint(x: sw/2, y: sh/2))
            }
        }
    }
    
    public init(superLayer: CALayer) {
        self.superLayer = superLayer
        
        let sw = superLayer.bounds.width
        let sh = superLayer.bounds.height
        
        // background layer
        backgroundLayer.frame = superLayer.bounds
        backgroundLayer.opacity = 0.0
        superLayer.addSublayer(backgroundLayer)
        
        // ripple layer
        let circleSize = CGFloat(max(sw, sh)) * CGFloat(ripplePercent)
        let rippleCornerRadius = circleSize/2
        
        rippleLayer.opacity = 0.0
        rippleLayer.cornerRadius = rippleCornerRadius
        setCircleLayerLocationAt(CGPoint(x: sw/2, y: sh/2))
        backgroundLayer.addSublayer(rippleLayer)
        
        // mask layer
        setMaskLayerCornerRadius(superLayer.cornerRadius)
        backgroundLayer.mask = maskLayer
    }
    
    open func superLayerDidResize() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = superLayer.bounds
        setMaskLayerCornerRadius(superLayer.cornerRadius)
        CATransaction.commit()
        setCircleLayerLocationAt(CGPoint(x: superLayer.bounds.width/2, y: superLayer.bounds.height/2))
    }
    
    open func enableOnlyCircleLayer() {
        backgroundLayer.removeFromSuperlayer()
        superLayer.addSublayer(rippleLayer)
    }
    
    open func setBackgroundLayerColor(_ color: UIColor) {
        backgroundLayer.backgroundColor = color.cgColor
    }
    
    open func setCircleLayerColor(_ color: UIColor) {
        rippleLayer.backgroundColor = color.cgColor
    }
    
    open func didChangeTapLocation(_ location: CGPoint) {
        if rippleLocation == .tapLocation {
            setCircleLayerLocationAt(location)
        }
    }
    
    open func setMaskLayerCornerRadius(_ cornerRadius: CGFloat) {
        maskLayer.path = UIBezierPath(roundedRect: backgroundLayer.bounds, cornerRadius: cornerRadius).cgPath
    }
    
    open func enableMask(_ enable: Bool = true) {
        backgroundLayer.mask = enable ? maskLayer : nil
    }
    
    open func setBackgroundLayerCornerRadius(_ cornerRadius: CGFloat) {
        backgroundLayer.cornerRadius = cornerRadius
    }
    
    fileprivate func setCircleLayerLocationAt(_ center: CGPoint) {
        let bounds = superLayer.bounds
        let width = bounds.width
        let height = bounds.height
        let subSize = CGFloat(max(width, height)) * CGFloat(ripplePercent)
        let subX = center.x - subSize/2
        let subY = center.y - subSize/2
        
        // disable animation when changing layer frame
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        rippleLayer.cornerRadius = subSize / 2
        rippleLayer.frame = CGRect(x: subX, y: subY, width: subSize, height: subSize)
        CATransaction.commit()
    }
    
    // MARK - Animation
    open func animateScaleForCircleLayer(_ fromScale: Float, toScale: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let rippleLayerAnim = CABasicAnimation(keyPath: "transform.scale")
        rippleLayerAnim.fromValue = fromScale
        rippleLayerAnim.toValue = toScale
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1.0
        opacityAnim.toValue = 0.0
        
        let groupAnim = CAAnimationGroup()
        groupAnim.duration = duration
        groupAnim.timingFunction = timingFunction.function
        groupAnim.isRemovedOnCompletion = false
        groupAnim.fillMode = kCAFillModeForwards
        
        groupAnim.animations = [rippleLayerAnim, opacityAnim]
        
        rippleLayer.add(groupAnim, forKey: nil)
    }
    
    open func animateAlphaForBackgroundLayer(_ timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let backgroundLayerAnim = CABasicAnimation(keyPath: "opacity")
        backgroundLayerAnim.fromValue = 1.0
        backgroundLayerAnim.toValue = 0.0
        backgroundLayerAnim.duration = duration
        backgroundLayerAnim.timingFunction = timingFunction.function
        backgroundLayer.add(backgroundLayerAnim, forKey: nil)
    }
    
    open func animateSuperLayerShadow(_ fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        animateShadowForLayer(superLayer, fromRadius: fromRadius, toRadius: toRadius, fromOpacity: fromOpacity, toOpacity: toOpacity, timingFunction: timingFunction, duration: duration)
    }
    
    open func animateMaskLayerShadow() {
        
    }
    
    fileprivate func animateShadowForLayer(_ layer: CALayer, fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let radiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
        radiusAnimation.fromValue = fromRadius
        radiusAnimation.toValue = toRadius
        
        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = fromOpacity
        opacityAnimation.toValue = toOpacity
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.timingFunction = timingFunction.function
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = kCAFillModeForwards
        groupAnimation.animations = [radiusAnimation, opacityAnimation]
        
        layer.add(groupAnimation, forKey: nil)
    }
}

@IBDesignable
open class MKTextField : UITextField {
    @IBInspectable open var padding: CGSize = CGSize(width: 5, height: 5)
    @IBInspectable open var floatingLabelBottomMargin: CGFloat = 2.0
    @IBInspectable open var floatingPlaceholderEnabled: Bool = false
    
    @IBInspectable open var rippleLocation: MKRippleLocation = .tapLocation {
        didSet {
            mkLayer.rippleLocation = rippleLocation
        }
    }
    
    @IBInspectable open var rippleAniDuration: Float = 0.75
    @IBInspectable open var backgroundAniDuration: Float = 1.0
    @IBInspectable open var shadowAniEnabled: Bool = true
    @IBInspectable open var rippleAniTimingFunction: MKTimingFunction = .linear
    
    @IBInspectable open var cornerRadius: CGFloat = 2.5 {
        didSet {
            layer.cornerRadius = cornerRadius
            mkLayer.setMaskLayerCornerRadius(cornerRadius)
        }
    }
    // color
    @IBInspectable open var rippleLayerColor: UIColor = UIColor(white: 0.45, alpha: 0.5) {
        didSet {
            mkLayer.setCircleLayerColor(rippleLayerColor)
        }
    }
    @IBInspectable open var backgroundLayerColor: UIColor = UIColor(white: 0.75, alpha: 0.25) {
        didSet {
            mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        }
    }
    
    // floating label
    @IBInspectable open var floatingLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 10.0) {
        didSet {
            floatingLabel.font = floatingLabelFont
        }
    }
    @IBInspectable open var floatingLabelTextColor: UIColor = UIColor.lightGray {
        didSet {
            floatingLabel.textColor = floatingLabelTextColor
        }
    }
    
    @IBInspectable open var bottomBorderEnabled: Bool = true {
        didSet {
            bottomBorderLayer?.removeFromSuperlayer()
            bottomBorderLayer = nil
            if bottomBorderEnabled {
                bottomBorderLayer = CALayer()
                bottomBorderLayer?.frame = CGRect(x: 0, y: layer.bounds.height - 1, width: bounds.width, height: 1)
                bottomBorderLayer?.backgroundColor = UIColor.MKColor.Grey.cgColor
                layer.addSublayer(bottomBorderLayer!)
            }
        }
    }
    @IBInspectable open var bottomBorderWidth: CGFloat = 1.0
    @IBInspectable open var bottomBorderColor: UIColor = UIColor.lightGray
    @IBInspectable open var bottomBorderHighlightWidth: CGFloat = 1.75
    
    override open var placeholder: String? {
        didSet {
            updateFloatingLabelText()
        }
    }
    override open var bounds: CGRect {
        didSet {
            mkLayer.superLayerDidResize()
        }
    }
    
    fileprivate lazy var mkLayer: MKLayer = MKLayer(superLayer: self.layer)
    fileprivate var floatingLabel: UILabel!
    fileprivate var bottomBorderLayer: CALayer?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupLayer()
    }
    
    fileprivate func setupLayer() {
        cornerRadius = 2.5
        layer.borderWidth = 1.0
        borderStyle = .none
        mkLayer.ripplePercent = 1.0
        mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        mkLayer.setCircleLayerColor(rippleLayerColor)
        
        // floating label
        floatingLabel = UILabel()
        floatingLabel.font = floatingLabelFont
        floatingLabel.alpha = 0.0
        updateFloatingLabelText()
        
        addSubview(floatingLabel)
    }
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        mkLayer.didChangeTapLocation(touch.location(in: self))
        
        // disabling this feature
        //        mkLayer.animateScaleForCircleLayer(0.45, toScale: 1.0, timingFunction: MKTimingFunction.Linear, duration: CFTimeInterval(self.rippleAniDuration))
        //        mkLayer.animateAlphaForBackgroundLayer(MKTimingFunction.Linear, duration: CFTimeInterval(self.backgroundAniDuration))
        
        return super.beginTracking(touch, with: event)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        bottomBorderLayer?.backgroundColor = isFirstResponder ? tintColor.cgColor : bottomBorderColor.cgColor
        let borderWidth = isFirstResponder ? bottomBorderHighlightWidth : bottomBorderWidth
        bottomBorderLayer?.frame = CGRect(x: 0, y: layer.bounds.height - borderWidth, width: layer.bounds.width, height: borderWidth)
        
        if !floatingPlaceholderEnabled {
            return
        }
        
        if !text!.isEmpty {
            floatingLabel.textColor = isFirstResponder ? tintColor : floatingLabelTextColor
            if floatingLabel.alpha == 0 {
                showFloatingLabel()
            }
        } else {
            hideFloatingLabel()
        }
        
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        var newRect = CGRect(x: rect.origin.x + padding.width, y: rect.origin.y,
                             width: rect.size.width - 2*padding.width, height: rect.size.height)
        
        if !floatingPlaceholderEnabled {
            return newRect
        }
        
        if !text!.isEmpty {
            let dTop = floatingLabel.font.lineHeight + floatingLabelBottomMargin
            newRect = UIEdgeInsetsInsetRect(newRect, UIEdgeInsets(top: dTop, left: 0.0, bottom: 0.0, right: 0.0))
        }
        return newRect
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}

// MARK - private methods
private extension MKTextField {
    func setFloatingLabelOverlapTextField() {
        let textRect = self.textRect(forBounds: bounds)
        var originX = textRect.origin.x
        switch textAlignment {
        case .center:
            originX += textRect.size.width/2 - floatingLabel.bounds.width/2
        case .right:
            originX += textRect.size.width - floatingLabel.bounds.width
        default:
            break
        }
        floatingLabel.frame = CGRect(x: originX, y: padding.height,
                                     width: floatingLabel.frame.size.width, height: floatingLabel.frame.size.height)
    }
    
    func showFloatingLabel() {
        let curFrame = floatingLabel.frame
        floatingLabel.frame = CGRect(x: curFrame.origin.x, y: bounds.height/2, width: curFrame.width, height: curFrame.height)
        UIView.animate(withDuration: 0.45, delay: 0.0, options: .curveEaseOut,
                       animations: {
                        self.floatingLabel.alpha = 1.0
                        self.floatingLabel.frame = curFrame
        }, completion: nil)
    }
    
    func hideFloatingLabel() {
        floatingLabel.alpha = 0.0
    }
    
    func updateFloatingLabelText() {
        floatingLabel.text = placeholder
        floatingLabel.sizeToFit()
        setFloatingLabelOverlapTextField()
    }
}



enum SwiftLocationError: Error {
	case serviceUnavailable
	case locationServicesUnavailable
}

/// Type of a request ID
public typealias RequestIDType = Int

//MARK: Handlers
// Location related handler
public typealias onSuccessLocate = ( (_ location: CLLocation?) -> Void)
public typealias onErrorLocate = ( (_ error: NSError?) -> Void)
// Generic timeout handler
public typealias onTimeoutReached = ( (Void) -> (TimeInterval?))
// Region/Beacon Proximity related handlers
public typealias onRegionEvent = ( (_ region: Any?) -> Void)
public typealias onRangingBacon = ( (_ beacons: [Any]) -> Void)
// Geocoding related handlers
public typealias onSuccessGeocoding = ( (_ place: CLPlacemark?) -> Void)
public typealias onErrorGeocoding = ( (_ error: NSError?) -> Void)

//MARK: Service Status Enum

/**
Apple location services are subject to authorization step. This enum indicate the current status of the location manager into the device. You can query it via SwiftLocation.state property.

- Available:    User has already granted this app permissions to access location services, and they are enabled and ready for use by this app.
Note: this state will be returned for both the "When In Use" and "Always" permission levels.
- Undetermined: User has not yet responded to the dialog that grants this app permission to access location services.
- Denied:       User has explicitly denied this app permission to access location services. (The user can enable permissions again for this app from the system Settings app.)
- Restricted:   User does not have ability to enable location services (e.g. parental controls, corporate policy, etc).
- Disabled:     User has turned off location services device-wide (for all apps) from the system Settings app.
*/
public enum ServiceStatus :Int {
	case available
	case undetermined
	case denied
	case restricted
	case disabled
}

//MARK: Service Type Enum

/**
For reverse geocoding service you can choose what service use to make your request.

- Apple:      Apple built-in CoreLocation services
- GoogleMaps: Google Geocoding Services (https://developers.google.com/maps/documentation/geocoding/intro)
*/
public enum Service: Int, CustomStringConvertible {
	case apple		= 0
	case googleMaps = 1
	
	public var description: String {
		get {
			switch self {
			case .apple:
				return "Apple"
			case .googleMaps:
				return "Google"
			}
		}
	}
}

//MARK: Accuracy

/**
Accuracy is used to set the minimum level of precision required during location discovery

- None:         Unknown level detail
- Country:      Country detail. It's used only for a single shot location request and uses IP based location discovery (no auth required). Inaccurate (>5000 meters, and/or received >10 minutes ago).
- City:         5000 meters or better, and received within the last 10 minutes. Lowest accuracy.
- Neighborhood: 1000 meters or better, and received within the last 5 minutes.
- Block:        100 meters or better, and received within the last 1 minute.
- House:        15 meters or better, and received within the last 15 seconds.
- Room:         5 meters or better, and received within the last 5 seconds. Highest accuracy.
*/
public enum Accuracy:Int, CustomStringConvertible {
	case none			= 0
	case country		= 1
	case city			= 2
	case neighborhood	= 3
	case block			= 4
	case house			= 5
	case room			= 6
	
	public var description: String {
		get {
			switch self {
			case .none:
				return "None"
			case .country:
				return "Country"
			case .city:
				return "City"
			case .neighborhood:
				return "Neighborhood"
			case .block:
				return "Block"
			case .house:
				return "House"
			case .room:
				return "Room"
			}
		}
	}
	
	/**
	This is the threshold of accuracy to validate a location
	
	- returns: value in meters
	*/
	func accuracyThreshold() -> Double {
		switch self {
		case .none:
			return Double.infinity
		case .country:
			return Double.infinity
		case .city:
			return 5000.0
		case .neighborhood:
			return 1000.0
		case .block:
			return 100.0
		case .house:
			return 15.0
		case .room:
			return 5.0
		}
	}
	
	/**
	Time threshold to validate the accuracy of a location
	
	- returns: in seconds
	*/
	func timeThreshold() -> Double {
		switch self {
		case .none:
			return Double.infinity
		case .country:
			return Double.infinity
		case .city:
			return 600.0
		case .neighborhood:
			return 300.0
		case .block:
			return 60.0
		case .house:
			return 15.0
		case .room:
			return 5.0
		}
	}
}

//MARK: ===== [PUBLIC] SwiftLocation Class =====

open class SwiftLocation: NSObject, CLLocationManagerDelegate {
	//MARK: Private vars
	fileprivate var manager: CLLocationManager // CoreLocationManager shared instance
	fileprivate var requests: [SwiftLocationRequest]! // This is the list of running requests (does not include geocode requests)
	fileprivate let blocksDispatchQueue = DispatchQueue(label: "SynchronizedArrayAccess", attributes: []) // sync operation queue for CGD
	
	//MARK: Public vars
	open static let shared = SwiftLocation()
	
	//MARK: Simulate location and location updates
	
	/// Set this to a valid non-nil location to receive it as current location for single location search
	open var fixedLocation: CLLocation?
	open var fixedLocationDictionary: [String: Any]?
	/// Set it to a valid existing gpx file url to receive positions during continous update
	//public var fixedLocationGPX: NSURL?
	
	
	/// This property report the current state of the CoreLocationManager service based on user authorization
	class var state: ServiceStatus {
		get {
			if CLLocationManager.locationServicesEnabled() == false {
				return .disabled
			} else {
				switch CLLocationManager.authorizationStatus() {
				case .notDetermined:
					return .undetermined
				case .denied:
					return .denied
				case .restricted:
					return .restricted
				case .authorizedAlways, .authorizedWhenInUse:
					return .available
				}
			}
		}
	}
	
	//MARK: Private Init
	
	/**
	Private init. This is called only to allocate the singleton instance
	
	- returns: the object itself, what else?
	*/
	override fileprivate init() {
		requests = []
		manager = CLLocationManager()
		super.init()
		manager.delegate = self
	}
	
	//MARK: [Public] Cancel a running request
	
	/**
	Cancel a running request
	
	- parameter identifier: identifier of the request
	
	- returns: true if request is marked as cancelled, no if it was not found
	*/
	open func cancelRequest(_ identifier: Int) -> Bool {
		if let request = request(identifier) as SwiftLocationRequest! {
			request.markAsCancelled(nil)
		}
		return false
	}
	
	/**
	Mark as cancelled any running request
	*/
	open func cancelAllRequests() {
		for request in requests {
			request.markAsCancelled(nil)
		}
	}
	
	//MARK: [Public] Reverse Geocoding

	/**
	Submits a forward-geocoding request using the specified string and optional region information.
	
	- parameter service:    service to use
	- parameter address:   A string describing the location you want to look up. For example, you could specify the string “1 Infinite Loop, Cupertino, CA” to locate Apple headquarters.
	- parameter region:    (Optional) A geographical region to use as a hint when looking up the specified address. Region is used only when service is set to Apple
	- parameter onSuccess: on success handler
	- parameter onFail:    on error handler
	*/
	open func reverseAddress(_ service: Service!, address: String!, region: CLRegion?, onSuccess: onSuccessGeocoding?, onFail: onErrorGeocoding?) {
		if service == Service.apple {
			reverseAppleAddress(address, region: region, onSuccess: onSuccess, onFail: onFail)
		} else {
			reverseGoogleAddress(address, onSuccess: onSuccess, onFail: onFail)
		}
	}
	
	/**
	This method submits the specified location data to the geocoding server asynchronously and returns.
	
	- parameter service:     service to use
	- parameter coordinates: coordinates to reverse
	- parameter onSuccess:	on success handler with CLPlacemarks objects
	- parameter onFail:		on error handler with error description
	*/
	open func reverseCoordinates(_ service: Service!, coordinates: CLLocationCoordinate2D!, onSuccess: onSuccessGeocoding?, onFail: onErrorGeocoding?) {
		if service == Service.apple {
			reverseAppleCoordinates(coordinates, onSuccess: onSuccess, onFail: onFail)
		} else {
			reverseGoogleCoordinates(coordinates, onSuccess: onSuccess, onFail: onFail)
		}
	}
	
	//MARK: [Public] Search Location / Subscribe Location Changes
	
	/**
	Get the current location from location manager with given accuracy
	
	- parameter accuracy:  minimum accuracy value to accept (country accuracy uses IP based location, not the CoreLocationManager, and it does not require user authorization)
	- parameter timeout:   search timeout. When expired, method return directly onFail
	- parameter onSuccess: handler called when location is found
	- parameter onFail:    handler called when location manager fails due to an error
	
	- returns: return an object to manage the request itself
	*/
	open func currentLocation(_ accuracy: Accuracy, timeout: TimeInterval, onSuccess: @escaping onSuccessLocate, onFail: @escaping onErrorLocate) throws -> RequestIDType {
		if let fixedLocation = fixedLocation as CLLocation! {
			// If a fixed location is set we want to return it
			onSuccess(fixedLocation)
			return -1 // request cannot be aborted, of course
		}
		
		if SwiftLocation.state == ServiceStatus.disabled {
			throw SwiftLocationError.locationServicesUnavailable
		}
		
		if accuracy == Accuracy.country {
			let newRequest = SwiftLocationRequest(requestType: RequestType.singleShotIPLocation, accuracy:accuracy, timeout: timeout, success: onSuccess, fail: onFail)
			locateByIP(newRequest, refresh: false, timeout: timeout, onEnd: { (place, error) -> Void in
				if error != nil {
					onFail(error)
				} else {
					onSuccess(place?.location)
				}
			})
			addRequest(newRequest)
			return newRequest.ID
		} else {
			let newRequest = SwiftLocationRequest(requestType: RequestType.singleShotLocation, accuracy:accuracy, timeout: timeout, success: onSuccess, fail: onFail)
			addRequest(newRequest)
			return newRequest.ID
		}
	}
	
	/**
	This method continously report found locations with desidered or better accuracy. You need to stop it manually by calling cancel() method into the request.
	
	- parameter accuracy:  minimum accuracy value to accept (country accuracy is not allowed)
	- parameter onSuccess: handler called each time a new position is found
	- parameter onFail:    handler called when location manager fail (the request itself is aborted automatically)
	
	- returns: return the id of the request. Use cancelRequest() to abort it.
	*/
	open func continuousLocation(_ accuracy: Accuracy, onSuccess: @escaping onSuccessLocate, onFail: @escaping onErrorLocate) throws -> RequestIDType {
		if SwiftLocation.state == ServiceStatus.disabled {
			throw SwiftLocationError.locationServicesUnavailable
		}
		let newRequest = SwiftLocationRequest(requestType: RequestType.continuousLocationUpdate, accuracy:accuracy, timeout: 0, success: onSuccess, fail: onFail)
		addRequest(newRequest)
		return newRequest.ID
	}
	
	/**
	This method continously return only significant location changes. This capability provides tremendous power savings for apps that want to track a user’s approximate location and do not need highly accurate position information. You need to stop it manually by calling cancel() method into the request.
	
	- parameter onSuccess: handler called each time a new position is found
	- parameter onFail:    handler called when location manager fail (the request itself is aborted automatically)
	
	- returns: return the id of the request. Use cancelRequest() to abort it.
	*/
	open func significantLocation(_ onSuccess: @escaping onSuccessLocate, onFail: @escaping onErrorLocate) throws -> RequestIDType {
		if SwiftLocation.state == ServiceStatus.disabled {
			throw SwiftLocationError.locationServicesUnavailable
		}
		let newRequest = SwiftLocationRequest(requestType: RequestType.continuousSignificantLocation, accuracy:Accuracy.none, timeout: 0, success: onSuccess, fail: onFail)
		addRequest(newRequest)
		return newRequest.ID
	}
	
	//MARK: [Public] Monitor Regions

	/**
	Start monitoring specified region by reporting when users move in/out from it. You must call this method once for each region you want to monitor. You need to stop it manually by calling cancel() method into the request.
	
	- parameter region:  region to monitor
	- parameter onEnter: handler called when user move into the region
	- parameter onExit:  handler called when user move out from the region
	
	- returns: return the id of the request. Use cancelRequest() to abort it.
	*/
	open func monitorRegion(_ region: CLRegion!, onEnter: onRegionEvent?, onExit: onRegionEvent?) throws -> RequestIDType? {
		// if beacons region monitoring is not available on this device we can't satisfy the request
		let isAvailable = CLLocationManager.isMonitoringAvailable(for: CLRegion.self)
		if isAvailable == true {
			let request = SwiftLocationRequest(region: region, onEnter: onEnter, onExit: onExit)
			manager.startMonitoring(for: region)
			self.updateLocationManagerStatus()
			return request.ID
		} else {
			throw SwiftLocationError.serviceUnavailable
		}
	}
	
	//MARK: [Public] Monitor Beacons Proximity

	/**
	Starts the delivery of notifications for beacons in the specified region.
	
	- parameter region:    region to monitor
	- parameter onRanging: handler called every time one or more beacon are in range, ordered by distance (closest is the first one)
	
	- returns: return the id of the request. Use cancelRequest() to abort it.
	*/
	open func monitorBeaconsInRegion(_ region: CLBeaconRegion!, onRanging: onRangingBacon?) throws -> RequestIDType? {
		let isAvailable = CLLocationManager.isRangingAvailable() // if beacons monitoring is not available on this device we can't satisfy the request
		if isAvailable == true {
			let request = SwiftLocationRequest(beaconRegion: region, onRanging: onRanging)
			addRequest(request)
			return request.ID
		} else {
			throw SwiftLocationError.serviceUnavailable
		}
	}
	
	//MARK: [Private] Google / Reverse Geocoding
	
	fileprivate func reverseGoogleCoordinates(_ coordinates: CLLocationCoordinate2D!, onSuccess: onSuccessGeocoding?, onFail: onErrorGeocoding?) {
		var APIURLString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinates.latitude),\(coordinates.longitude)" as NSString
		APIURLString = APIURLString.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
		let APIURL = URL(string: APIURLString as String)
		let APIURLRequest = URLRequest(url: APIURL!)
		NSURLConnection.sendAsynchronousRequest(APIURLRequest, queue: OperationQueue.main) { (response, data, error) in
			if error != nil {
				onFail?(error as NSError?)
			} else {
                if data != nil {
                    let jsonResult: NSDictionary = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                    let (error,noResults) = self.validateGoogleJSONResponse(jsonResult)
                    if noResults == true { // request is ok but not results are returned
                        onSuccess?(nil)
                    } else if (error != nil) { // something went wrong with request
                        onFail?(error)
                    } else { // we have some good results to show
                        let address = SwiftLocationParser()
                        address.parseGoogleLocationData(jsonResult)
                        let placemark:CLPlacemark = address.getPlacemark()
                        onSuccess?(placemark)
                    }
                }
			}
		}
	}
	
	fileprivate func reverseGoogleAddress(_ address: String!, onSuccess: onSuccessGeocoding?, onFail: onErrorGeocoding?) {
		var APIURLString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)" as NSString
		APIURLString = APIURLString.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
		let APIURL = URL(string: APIURLString as String)
		let APIURLRequest = URLRequest(url: APIURL!)
		NSURLConnection.sendAsynchronousRequest(APIURLRequest, queue: OperationQueue.main) { (response, data, error) in
			if error != nil {
				onFail?(error as NSError?)
			} else {
                if data != nil {
                    let jsonResult: NSDictionary = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                    let (error,noResults) = self.validateGoogleJSONResponse(jsonResult)
                    if noResults == true { // request is ok but not results are returned
                        onSuccess?(nil)
                    } else if (error != nil) { // something went wrong with request
                        onFail?(error)
                    } else { // we have some good results to show
                        let address = SwiftLocationParser()
                        address.parseGoogleLocationData(jsonResult)
                        let placemark:CLPlacemark = address.getPlacemark()
                        onSuccess?(placemark)
                    }
                }
			}
		}
	}
	
	fileprivate func validateGoogleJSONResponse(_ jsonResult: NSDictionary!) -> (error: NSError?, noResults: Bool?) {
		var status = jsonResult.value(forKey: "status") as! NSString
		status = status.lowercased as NSString
		if status.isEqual(to: "ok") == true { // everything is fine, the sun is shining and we have results!
			return (nil,false)
		} else if status.isEqual(to: "zero_results") == true { // No results error
			return (nil,true)
		} else if status.isEqual(to: "over_query_limit") == true { // Quota limit was excedeed
			let message	= "Query quota limit was exceeded"
			return (NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : message]),false)
		} else if status.isEqual(to: "request_denied") == true { // Request was denied
			let message	= "Request denied"
			return (NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : message]),false)
		} else if status.isEqual(to: "invalid_request") == true { // Invalid parameters
			let message	= "Invalid input sent"
			return (NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : message]),false)
		}
		return (nil,false) // okay!
	}
	
	//MARK: [Private] Apple / Reverse Geocoding
	
	fileprivate func reverseAppleCoordinates(_ coordinates: CLLocationCoordinate2D!, onSuccess: onSuccessGeocoding?, onFail: onErrorGeocoding? ) {
		let geocoder = CLGeocoder()
		let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
		geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
			if error != nil {
				onFail?(error as NSError?)
			} else {
				if let placemark = placemarks?[0] {
					let address = SwiftLocationParser()
					address.parseAppleLocationData(placemark)
					onSuccess?(address.getPlacemark())
				} else {
					onSuccess?(nil)
				}
			}
		})
	}
	
	fileprivate func reverseAppleAddress(_ address: String!, region: CLRegion?, onSuccess: onSuccessGeocoding?, onFail: onErrorGeocoding?) {
		let geocoder = CLGeocoder()
		if region != nil {
			geocoder.geocodeAddressString(address, in: region, completionHandler: { (placemarks, error) in
				if error != nil {
					onFail?(error as NSError?)
				} else {
					if let placemark = placemarks?[0]  {
						let address = SwiftLocationParser()
						address.parseAppleLocationData(placemark)
						onSuccess?(address.getPlacemark())
					} else {
						onSuccess?(nil)
					}
				}
			})
		} else {
			geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
				if error != nil {
					onFail?(error as NSError?)
				} else {
					if let placemark = placemarks?[0] {
						let address = SwiftLocationParser()
						address.parseAppleLocationData(placemark)
						onSuccess?(address.getPlacemark())
					} else {
						onSuccess?(nil)
					}
				}
			})
		}
	}
	
	//MARK: [Private] Helper Methods
	
	fileprivate func locateByIP(_ request: SwiftLocationRequest, refresh: Bool = false, timeout: TimeInterval, onEnd: ( (_ place: CLPlacemark?, _ error: NSError?) -> Void)?) {
		let policy = (refresh == false ? NSURLRequest.CachePolicy.returnCacheDataElseLoad : NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData)
		let URLRequest = Foundation.URLRequest(url: URL(string: "https://ip-api.com/json")!, cachePolicy: policy, timeoutInterval: timeout)
        NSURLConnection.sendAsynchronousRequest(URLRequest, queue: OperationQueue.main) { response, data, error in
            if request.isCancelled == true {
                onEnd?(nil, nil)
                return
            }
            if let data = data as Data? {
                do {
                    if let resultDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        let address = SwiftLocationParser()
                        address.parseIPLocationData(resultDict)
                        let placemark = address.getPlacemark()
                        onEnd?(placemark, nil)
                    }
                } catch let error {
                    onEnd?(nil, NSError(domain: "\(error)", code: 1, userInfo: nil))
                }
            }
        }
	}
	
	/**
	Request will be added to the pool and related services are enabled automatically
	
	- parameter request: request to add
	*/
	fileprivate func addRequest(_ request: SwiftLocationRequest!) {
		// Add a new request to the array. Please note: add/remove is a sync operation due to avoid problems in a multitrheading env
		blocksDispatchQueue.sync {
			self.requests.append(request)
			self.updateLocationManagerStatus()
		}
	}
	
	/**
	Search for a request with given identifier into the pool of requests
	
	- parameter identifier: identifier of the request
	
	- returns: the request object or nil
	*/
	fileprivate func request(_ identifier: Int?) -> SwiftLocationRequest? {
		if let identifier = identifier as Int! {
			for cRequest in self.requests {
				if cRequest.ID == identifier {
					return cRequest
				}
			}
		}
		return nil
	}
	
	/**
	Return the requesta associated with a given CLRegion object
	
	- parameter region: region instance
	
	- returns: request if found, nil otherwise.
	*/
	fileprivate func requestForRegion(_ region: CLRegion!) -> SwiftLocationRequest? {
		for request in requests {
			if request.type == RequestType.regionMonitor && request.region == region {
				return request
			}
		}
		return nil
	}
	
	/**
	This method is called to complete an existing request, send result to the appropriate handler and remove it from the pool
	(the last action will not occur for subscribe continuosly location notifications, until the request is not marked as cancelled)
	
	- parameter request: request to complete
	- parameter object:  optional return object
	- parameter error:   optional error to report
	*/
	fileprivate func completeRequest(_ request: SwiftLocationRequest!, object: Any?, error: NSError?) {
		
		if request.type == RequestType.regionMonitor { // If request is a region monitor we need to explictly stop it
			manager.stopMonitoring(for: request.region!)
		} else if (request.type == RequestType.beaconRegionProximity) { // If request is a proximity beacon monitor we need to explictly stop it
			manager.stopRangingBeacons(in: request.beaconReg!)
		}
		
		// Sync remove item from requests pool
		blocksDispatchQueue.sync {
			var idx = 0
			for cRequest in self.requests {
				if cRequest.ID == request.ID {
					cRequest.stopTimeout() // stop any running timeout timer
					if	cRequest.type == RequestType.continuousSignificantLocation ||
						cRequest.type == RequestType.continuousLocationUpdate ||
						cRequest.type == RequestType.singleShotLocation ||
						cRequest.type == RequestType.singleShotIPLocation ||
						cRequest.type == RequestType.beaconRegionProximity {
						// for location related event we want to report the last fetched result
						if error != nil {
							cRequest.onError?(error)
						} else {
							if object != nil {
								cRequest.onSuccess?(object as! CLLocation?)
							}
						}
					}
					// If result is not continous location update notifications or, anyway, for any request marked as cancelled
					// we want to remove it from the pool
					if cRequest.isCancelled == true || cRequest.type != RequestType.continuousLocationUpdate {
						self.requests.remove(at: idx)
					}
				}
				idx += 1
			}
			// Turn off any non-used hardware based upon the new list of running requests
			self.updateLocationManagerStatus()
		}
	}
	
	/**
	This method return the highest accuracy you want to receive into the current bucket of requests
	
	- returns: highest accuracy level you want to receive
	*/
	fileprivate func highestRequiredAccuracy() -> CLLocationAccuracy {
		var highestAccuracy = CLLocationAccuracy(Double.infinity)
		for request in requests {
			let accuracyLevel = CLLocationAccuracy(request.desideredAccuracy.accuracyThreshold())
			if accuracyLevel < highestAccuracy {
				highestAccuracy = accuracyLevel
			}
		}
		return highestAccuracy
	}
	
	/**
	This method simply turn off/on hardware required by the list of active running requests.
	The same method also ask to the user permissions to user core location.
	*/
	fileprivate func updateLocationManagerStatus() {
		if requests.count > 0 {
			let hasAlwaysKey = (Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil)
			let hasWhenInUseKey = (Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil)
			if hasAlwaysKey == true {
				manager.requestAlwaysAuthorization()
			} else if hasWhenInUseKey == true {
				manager.requestWhenInUseAuthorization()
			} else {
				// You've forgot something essential
				assert(false, "To use location services in iOS 8+, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.")
			}
		}
		
		// Location Update
		if hasActiveRequests([RequestType.continuousLocationUpdate,RequestType.singleShotLocation]) == true {
			let requiredAccuracy = self.highestRequiredAccuracy()
			if requiredAccuracy != manager.desiredAccuracy {
				manager.stopUpdatingLocation()
				manager.desiredAccuracy = requiredAccuracy
			}
            if #available(iOS 9.0, *) {
                manager.allowsBackgroundLocationUpdates = true
            }
			manager.startUpdatingLocation()
		} else {
			manager.stopUpdatingLocation()
		}
		// Significant Location Changes
		if hasActiveRequests([RequestType.continuousSignificantLocation]) == true {
			manager.startMonitoringSignificantLocationChanges()
		} else {
			manager.stopMonitoringSignificantLocationChanges()
		}
		// Beacon/Region monitor is turned off automatically on completeRequest()
		let beaconRegions = self.activeRequests([RequestType.beaconRegionProximity])
		for beaconRegion in beaconRegions {
			manager.startRangingBeacons(in: beaconRegion.beaconReg!)
		}
	}
	
	/**
	Return true if a request into the pool is of type described by the list of types passed
	
	- parameter list: allowed types
	
	- returns: true if at least one request with one the specified type is running
	*/
	fileprivate func hasActiveRequests(_ list: [RequestType]) -> Bool! {
		for request in requests {
			let idx = list.index(of: request.type)
			if idx != nil {
				return true
			}
		}
		return false
	}
	
	/**
	Return the list of all request of a certain type
	
	- parameter list: list of types to filter
	
	- returns: output list with filtered active requests
	*/
	fileprivate func activeRequests(_ list: [RequestType]) -> [SwiftLocationRequest] {
		var filteredList : [SwiftLocationRequest] = []
		for request in requests {
			let idx = list.index(of: request.type)
			if idx != nil {
				filteredList.append(request)
			}
		}
		return filteredList
	}
	
	/**
	In case of an error we want to expire all queued notifications
	
	- parameter error: error to notify
	*/
	fileprivate func expireAllRequests(_ error: NSError?, types: [RequestType]?) {
		for request in requests {
			let canMark = (types == nil ? true : (types!.index(of: request.type) != nil))
			if canMark == true {
				request.markAsCancelled(error)
			}
		}
	}
	
	//MARK: [Private] Location Manager Delegate
	
	open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		locationsReceived(locations)
	}
	
	fileprivate func locationsReceived(_ locations: [Any]!) {
		if let location = locations.last as? CLLocation {
			for request in requests {
				if request.isAcceptable(location) == true {
					completeRequest(request, object: location, error: nil)
				}
			}
		}
	}
	
	open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		let expiredTypes = [RequestType.continuousLocationUpdate,
							RequestType.continuousSignificantLocation,
							RequestType.singleShotLocation,
							RequestType.continuousHeadingUpdate,
							RequestType.regionMonitor]
		expireAllRequests(error as NSError?, types: expiredTypes)
	}
	
	open func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
			// Clear out any pending location requests (which will execute the blocks with a status that reflects
			// the unavailability of location services) since we now no longer have location services permissions
			let err = NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : "Location services denied/restricted by parental control"])
			locationManager(manager, didFailWithError: err)
		} else if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
			for request in requests {
				request.startTimeout(nil)
			}
			updateLocationManagerStatus()
		} else if status == CLAuthorizationStatus.notDetermined {
		}
	}
	
	open func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		let request = requestForRegion(region)
		request?.onRegionEnter?(region)
	}
	
	open func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		let request = requestForRegion(region)
		request?.onRegionExit?(region)
	}
	
	open func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		for request in requests {
			if request.beaconReg == region {
				request.onRangingBeaconEvent?(beacons)
			}
		}
	}
	
	open func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
		let expiredTypes = [RequestType.beaconRegionProximity]
		expireAllRequests(error as NSError?, types: expiredTypes)
	}

}

/**
This is the request type

- SingleShotLocation:            Single location request with desidered accuracy level
- SingleShotIPLocation:          Single location request with IP-based location search (used automatically with accuracy set to Country)
- ContinuousLocationUpdate:      Continous location update
- ContinuousSignificantLocation: Significant location update requests
- ContinuousHeadingUpdate:       Continous heading update requests
- RegionMonitor:                 Monitor specified region
- BeaconRegionProximity:         Search for beacon services nearby the device
*/
enum RequestType {
	case singleShotLocation
	case singleShotIPLocation
	case continuousLocationUpdate
	case continuousSignificantLocation
	case continuousHeadingUpdate
	case regionMonitor
	case beaconRegionProximity
}

private extension CLLocation {
	func accuracyOfLocation() -> Accuracy! {
		let timeSinceUpdate = fabs( self.timestamp.timeIntervalSinceNow)
		let horizontalAccuracy = self.horizontalAccuracy
		
		if horizontalAccuracy <= Accuracy.room.accuracyThreshold() &&
			timeSinceUpdate <= Accuracy.room.timeThreshold() {
				return Accuracy.room
				
		} else if horizontalAccuracy <= Accuracy.house.accuracyThreshold() &&
			timeSinceUpdate <= Accuracy.house.timeThreshold() {
				return Accuracy.house
				
		} else if horizontalAccuracy <= Accuracy.block.accuracyThreshold() &&
			timeSinceUpdate <= Accuracy.block.timeThreshold() {
				return Accuracy.block
				
		} else if horizontalAccuracy <= Accuracy.neighborhood.accuracyThreshold() &&
			timeSinceUpdate <= Accuracy.neighborhood.timeThreshold() {
				return Accuracy.neighborhood
				
		} else if horizontalAccuracy <= Accuracy.city.accuracyThreshold() &&
			timeSinceUpdate <= Accuracy.city.timeThreshold() {
				return Accuracy.city
		} else {
			return Accuracy.none
		}
	}
}

//MARK: ===== [PRIVATE] SwiftLocationRequest Class =====

var requestNextID: RequestIDType = 0

/// This is the class which represent a single request.
/// Usually you should not interact with it. The only action you can perform on it is to call the cancel method to abort a running request.
open class SwiftLocationRequest: NSObject {
	fileprivate(set) var type: RequestType
	fileprivate(set) var ID: RequestIDType
	fileprivate(set) var isCancelled: Bool!
	var onTimeOut: onTimeoutReached?
	
	// location related handlers
	fileprivate var onSuccess: onSuccessLocate?
	fileprivate var onError: onErrorLocate?
	
	// region/beacon related handlers
	fileprivate var region: CLRegion?
	fileprivate var beaconReg: CLBeaconRegion?
	fileprivate var onRegionEnter: onRegionEvent?
	fileprivate var onRegionExit: onRegionEvent?
	fileprivate var onRangingBeaconEvent: onRangingBacon?
	
	
	var desideredAccuracy: Accuracy!
	fileprivate var timeoutTimer: Timer?
	fileprivate var timeoutInterval: TimeInterval
	fileprivate var hasTimeout: Bool!
	
	//MARK: Init - Private Methods
	fileprivate init(requestType: RequestType, accuracy: Accuracy,timeout: TimeInterval, success: @escaping onSuccessLocate, fail: onErrorLocate?) {
		type = requestType
		requestNextID += 1
		ID = requestNextID
		isCancelled = false
		onSuccess = success
		onError = fail
		desideredAccuracy = accuracy
		timeoutInterval = timeout
		hasTimeout = false
		super.init()
		if SwiftLocation.state == ServiceStatus.available {
			self.startTimeout(nil)
		}
	}
	
	fileprivate init(region: CLRegion!, onEnter: onRegionEvent?, onExit: onRegionEvent?) {
		type = RequestType.regionMonitor
		requestNextID += 1
		ID = requestNextID
		isCancelled = false
		onRegionEnter = onEnter
		onRegionExit = onExit
		desideredAccuracy = Accuracy.none
		timeoutInterval = 0
		hasTimeout = false
		super.init()
	}
	
	fileprivate init(beaconRegion: CLBeaconRegion!, onRanging: onRangingBacon?) {
		type = RequestType.beaconRegionProximity
		requestNextID += 1
		ID = requestNextID
		isCancelled = false
		onRangingBeaconEvent = onRanging
		desideredAccuracy = Accuracy.none
		timeoutInterval = 0
		hasTimeout = false
		beaconReg = beaconRegion
		super.init()
	}
	
	//MARK: Public Methods
	
	/**
	Cancel method abort a running request
	*/
	fileprivate func markAsCancelled(_ error: NSError?) {
		isCancelled = true
		stopTimeout()
		SwiftLocation.shared.completeRequest(self, object: nil, error: error)
	}
	
	//MARK: Private Methods
	fileprivate func isAcceptable(_ location: CLLocation) -> Bool! {
		if isCancelled == true {
			return false
		}
		if desideredAccuracy == Accuracy.none {
			return true
		}
		let locAccuracy: Accuracy! = location.accuracyOfLocation()
		let valid = (locAccuracy.rawValue >= desideredAccuracy.rawValue)
		return valid
	}
	
	fileprivate func startTimeout(_ forceValue: TimeInterval?) {
		if hasTimeout == false && timeoutInterval > 0 {
			let value = (forceValue != nil ? forceValue! : timeoutInterval)
			timeoutTimer = Timer.scheduledTimer(timeInterval: value, target: self, selector: #selector(SwiftLocationRequest.timeoutReached), userInfo: nil, repeats: false)
		}
	}
	
	fileprivate func stopTimeout() {
		timeoutTimer?.invalidate()
		timeoutTimer = nil
	}
	
	open func timeoutReached() {
		let additionalTime: TimeInterval? = onTimeOut?()
		if additionalTime == nil {
			timeoutTimer?.invalidate()
			timeoutTimer = nil
			hasTimeout = true
			isCancelled = false
			let error = NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : "Timeout reached"])
			SwiftLocation.shared.completeRequest(self, object: nil, error: error)
		} else {
			hasTimeout = false
			startTimeout(additionalTime!)
		}
	}
}

//MARK: ===== [PRIVATE] SwiftLocationParser Class =====

// Portions of this class are part of the LocationManager mady by varshylmobile (AddressParser class):
// (Made by https://github.com/varshylmobile/LocationManager)

private class SwiftLocationParser: NSObject {
	fileprivate var latitude = NSString()
	fileprivate var longitude  = NSString()
	fileprivate var streetNumber = NSString()
	fileprivate var route = NSString()
	fileprivate var locality = NSString()
	fileprivate var subLocality = NSString()
	fileprivate var formattedAddress = NSString()
	fileprivate var administrativeArea = NSString()
	fileprivate var administrativeAreaCode = NSString()
	fileprivate var subAdministrativeArea = NSString()
	fileprivate var postalCode = NSString()
	fileprivate var country = NSString()
	fileprivate var subThoroughfare = NSString()
	fileprivate var thoroughfare = NSString()
	fileprivate var ISOcountryCode = NSString()
	fileprivate var state = NSString()
	
	override init() {
		super.init()
	}
	
	fileprivate func parseIPLocationData(_ JSON: NSDictionary) -> Bool {
		let status = JSON["status"] as? String
		if status != "success" {
			return false
		}
		self.country = JSON["country"] as! NSString
		self.ISOcountryCode = JSON["countryCode"] as! NSString
		if let lat = JSON["lat"] as? NSNumber, let lon = JSON["lon"] as? NSNumber {
			self.longitude = lat.description as NSString
			self.latitude = lon.description as NSString
		}
		self.postalCode = JSON["zip"] as! NSString
		return true
	}
	
	fileprivate func parseAppleLocationData(_ placemark:CLPlacemark) {
		let addressLines = placemark.addressDictionary?["FormattedAddressLines"] as! NSArray
		self.streetNumber = placemark.thoroughfare as NSString? ?? ""
		self.locality = placemark.locality as NSString? ?? ""
		self.postalCode = placemark.postalCode as NSString? ?? ""
		self.subLocality = placemark.subLocality as NSString? ?? ""
		self.administrativeArea = placemark.administrativeArea as NSString? ?? ""
		self.country = placemark.country as NSString? ?? ""
        if let location = placemark.location {
            self.longitude = location.coordinate.longitude.description as NSString;
            self.latitude = location.coordinate.latitude.description as NSString
        }
		if addressLines.count>0 {
			self.formattedAddress = addressLines.componentsJoined(by: ", ") as NSString
		} else {
			self.formattedAddress = ""
		}
	}
	
	fileprivate func parseGoogleLocationData(_ resultDict:NSDictionary) {
		let locationDict = (resultDict.value(forKey: "results") as! NSArray).firstObject as! NSDictionary
		let formattedAddrs = locationDict.object(forKey: "formatted_address") as! NSString
		
		let geometry = locationDict.object(forKey: "geometry") as! NSDictionary
		let location = geometry.object(forKey: "location") as! NSDictionary
		let lat = location.object(forKey: "lat") as! Double
		let lng = location.object(forKey: "lng") as! Double
		
		self.latitude = lat.description as NSString
		self.longitude = lng.description as NSString
		
		let addressComponents = locationDict.object(forKey: "address_components") as! NSArray
		self.subThoroughfare = component("street_number", inArray: addressComponents, ofType: "long_name")
		self.thoroughfare = component("route", inArray: addressComponents, ofType: "long_name")
		self.streetNumber = self.subThoroughfare
		self.locality = component("locality", inArray: addressComponents, ofType: "long_name")
		self.postalCode = component("postal_code", inArray: addressComponents, ofType: "long_name")
		self.route = component("route", inArray: addressComponents, ofType: "long_name")
		self.subLocality = component("subLocality", inArray: addressComponents, ofType: "long_name")
		self.administrativeArea = component("administrative_area_level_1", inArray: addressComponents, ofType: "long_name")
		self.administrativeAreaCode = component("administrative_area_level_1", inArray: addressComponents, ofType: "short_name")
		self.subAdministrativeArea = component("administrative_area_level_2", inArray: addressComponents, ofType: "long_name")
		self.country =  component("country", inArray: addressComponents, ofType: "long_name")
		self.ISOcountryCode =  component("country", inArray: addressComponents, ofType: "short_name")
		self.formattedAddress = formattedAddrs;
	}
	
	fileprivate func getPlacemark() -> CLPlacemark {
        var addressDict = [String:Any]()
		let formattedAddressArray = self.formattedAddress.components(separatedBy: ", ") as Array
		
		let kSubAdministrativeArea = "SubAdministrativeArea"
		let kSubLocality           = "SubLocality"
		let kState                 = "State"
		let kStreet                = "Street"
		let kThoroughfare          = "Thoroughfare"
		let kFormattedAddressLines = "FormattedAddressLines"
		let kSubThoroughfare       = "SubThoroughfare"
		let kPostCodeExtension     = "PostCodeExtension"
		let kCity                  = "City"
		let kZIP                   = "ZIP"
		let kCountry               = "Country"
		let kCountryCode           = "CountryCode"
		
        addressDict[kSubAdministrativeArea] = self.subAdministrativeArea
        addressDict[kSubLocality] = self.subLocality
        addressDict[kState] = self.administrativeAreaCode
        addressDict[kStreet] = formattedAddressArray.first! as NSString
        addressDict[kThoroughfare] = self.thoroughfare
        addressDict[kFormattedAddressLines] = formattedAddressArray as Any 
        addressDict[kSubThoroughfare] = self.subThoroughfare
        addressDict[kPostCodeExtension] = "" as Any 
        addressDict[kCity] = self.locality
        addressDict[kZIP] = self.postalCode
		addressDict[kCountry] = self.country
        addressDict[kCountryCode] = self.ISOcountryCode
		
		let lat = self.latitude.doubleValue
		let lng = self.longitude.doubleValue
		let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
		
		let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
		return (placemark as CLPlacemark)
	}
	
    fileprivate func component(_ component:NSString,inArray:NSArray,ofType:NSString) -> NSString {
        let index:NSInteger = inArray.indexOfObject(options: NSEnumerationOptions.concurrent, passingTest: { (obj, idx, stop) -> Bool in
            let objDict:NSDictionary = obj as! NSDictionary
            let types:NSArray = objDict.object(forKey: "types") as! NSArray
            let type = types.firstObject as! NSString
            return type.isEqual(to: component as String)
        })
        if index == NSNotFound { return "" }
        if index >= inArray.count { return "" }
        let type = ((inArray.object(at: index) as! NSDictionary).value(forKey: ofType as String)!) as! NSString
        if type.length > 0 { return type }
        return ""
    }
}

extension UILabel {
    func textHeight(with width: CGFloat) -> CGFloat {
        guard let text = text else {
            return 0
        }
        return text.height(with: width, font: font)
    }
    
    func attributedTextHeight(with width: CGFloat) -> CGFloat {
        guard let attributedText = attributedText else {
            return 0
        }
        return attributedText.height(with: width)
    }
}

extension String {
    func height(with width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
        return actualSize.height
    }
}

extension NSAttributedString {
    func height(with width: CGFloat) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], context: nil)
        return actualSize.height
    }
}



