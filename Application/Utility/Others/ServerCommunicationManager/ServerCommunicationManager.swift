//
//  ServerCommunicationManager.swift
//  Orahi
//
//  Created by Alok Singh on 01/01/17.
//  Copyright © 2016 Orahi. All rights reserved.
//

//MARK: - ServerCommunicationManager : This class handles communication of application with its Server.

import Foundation
import AFNetworking

//MARK: - ServerCommunicationConstants
struct ServerCommunicationConstants {
    static let RESPONSE_CODE_KEY = "status"
    static let RESPONSE_CODE_SUCCESS_VALUE = "Optional(1)"
    static let RESPONSE_CODE_FAILURE_VALUE = "Optional(0)"
    static let RESPONSE_MESSAGE_KEY = "message"
}

//MARK: - Response Error Handling Options
enum ResponseErrorOption {
    case dontShowErrorResponseMessage
    case showErrorResponseWithUsingNotification
    case showErrorResponseWithUsingPopUp
}

//MARK: - Response Error Handling Options
enum ApiRequestType {
    case get
    case post
}

//MARK: - Completion block
typealias WSCompletionBlock = (_ responseData :NSDictionary?) ->()
typealias WSCompletionBlockForFile = (_ responseData :NSData?) ->()

//MARK: - Custom methods
extension ServerCommunicationManager {
    
}

//MARK: - Private
class ServerCommunicationManager: NSObject {
    
    var completionBlock: WSCompletionBlock?
    var responseErrorOption: ResponseErrorOption?
    var progressIndicatorText: String?
    var returnFailureResponseAlso = false
    var returnFailureUnParsedDataIfParsingFails = false
    var showSuccessResponseMessage = false
    var attachCommonUserDetails = true
    var attachCommonDeviceDetails = true
    var showDebugInformationAboutRequestInNotification = false
    
    /// Check for cache and return from cache if possible.
    ///
    /// - parameter body: parameters to set in Body of the request
    /// - returns: bool (wether cache was used or not)
    func loadFromCacheIfPossible(_ body:NSDictionary? , urlString:NSString? ,completionBlock: WSCompletionBlock? , maxAgeInSeconds:Float)->(Bool){
        return false
    }
    
    func updateSecurityPolicy(_ manager:AFHTTPSessionManager){
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        securityPolicy.validatesDomainName = false
        securityPolicy.allowInvalidCertificates = true
        manager.securityPolicy = securityPolicy
    }
    
    /// Perform  GET Request.
    ///
    /// - parameter body: parameters to set in Body of the request
    /// - returns: parsed server response via completionBlock
    func performGetRequest(_ body:NSDictionary? , urlString:String ,completionBlock: WSCompletionBlock?,methodName:String)->(){
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            if isInternetConnectivityAvailable(true)==false {
                return;
            }
            let url = URL(string: urlString)
            
            let requestDetails = "\n\n\n                  HITTING URL\n\n \(url!.absoluteString)\n\n\n                  WITH GET REQUEST\n\n\(safeString(body, alternate: ""))\n\n"
            logMessage(requestDetails)
            if self.showDebugInformationAboutRequestInNotification {
                showNotification(requestDetails, showOnNavigation: true, showAsError: false, duration: 5)
            }
            
            if self.progressIndicatorText != nil{
                showActivityIndicator(self.progressIndicatorText!);
            }
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            self.updateSecurityPolicy(manager)
            manager.get(urlString, parameters: body, progress: { (progress) -> Void in
                if self.progressIndicatorText != nil{
                    progressForShowingOnActivityIndicator = progress
                }
            }, success: { (urlSessionDataTask, responseObject) -> Void in
                self.verifyServerResponse(responseObject , error: nil, completionBlock: completionBlock,methodName: methodName as NSString?)
            }){(urlSessionDataTask, error) -> Void in
                self.verifyServerResponse(nil, error: error as NSError, completionBlock: completionBlock,methodName: methodName as NSString?)
            }
        }
    }
    
    /// Perform Get Request For Downloading file data.
    ///
    /// - parameter url: url to download file
    /// - returns: fileData via completionBlock
    func performDownloadGetRequest(_ urlString:NSString? ,completionBlock: WSCompletionBlockForFile?,methodName:String)->(){
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            if isInternetConnectivityAvailable(true)==false {
                return;
            }
            if self.progressIndicatorText != nil{
                showActivityIndicator(self.progressIndicatorText!);
            }
            let url = URL(string: urlString as! String)

            let requestDetails = "\n\n\n                  HITTING URL TO DOWNLOAD FILE\n\n \((url!.absoluteString))\n\n\n"
            logMessage(requestDetails)
            if self.showDebugInformationAboutRequestInNotification {
                showNotification(requestDetails, showOnNavigation: true, showAsError: false, duration: 5)
            }

            
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            manager.requestSerializer = AFHTTPRequestSerializer()
            self.updateSecurityPolicy(manager)
            self.addCommonInformationInHeader(manager.requestSerializer)
            manager.get(urlString as! String, parameters: nil, progress: { (progress) -> Void in
                if self.progressIndicatorText != nil{
                    progressForShowingOnActivityIndicator = progress
                }
            }, success: { (urlSessionDataTask, responseObject) -> Void in
                completionBlock?(responseObject as! Data? as NSData?)
                execMain({(returnedData) -> () in
                    if self.progressIndicatorText != nil{
                        hideActivityIndicator()
                    }
                })
            }){(urlSessionDataTask, error) -> Void in
                self.showServerNotRespondingMessage()
                execMain({(returnedData) -> () in
                    if self.progressIndicatorText != nil{
                        hideActivityIndicator()
                    }
                })
            }
        }
    }
    
    /// Perform Json Encoded Post Request.
    ///
    /// - parameter body: parameters to set in Body of the request
    /// - returns: parsed server response via completionBlock
    func performJsonPostRequest(_ body:NSDictionary? , urlString:NSString? ,completionBlock: WSCompletionBlock?,methodName:String)->(){
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            if isInternetConnectivityAvailable(true)==false {
                return;
            }
            if self.progressIndicatorText != nil{
                showActivityIndicator(self.progressIndicatorText!)
            }
            let url = URL(string: urlString as! String)
           
            let requestDetails = "\n\n\n                  HITTING URL\n\n \((url!.absoluteString))\n\n\n                  WITH POST JSON BODY\n\n\(safeString(body, alternate: ""))\n\n"
            logMessage(requestDetails)
            if self.showDebugInformationAboutRequestInNotification {
                showNotification(requestDetails, showOnNavigation: true, showAsError: false, duration: 5)
            }

            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            manager.requestSerializer = AFJSONRequestSerializer()
            self.updateSecurityPolicy(manager)
            self.addCommonInformationInHeader(manager.requestSerializer)
            manager.post(urlString as! String, parameters: body, progress: { (progress) -> Void in
                if self.progressIndicatorText != nil{
                    progressForShowingOnActivityIndicator = progress
                }
            }, success: { (urlSessionDataTask, responseObject) -> Void in
                self.verifyServerResponse(responseObject , error: nil, completionBlock: completionBlock,methodName: methodName as NSString?)
            }) { (urlSessionDataTask, error) -> Void in
                self.verifyServerResponse(nil, error: error as NSError, completionBlock: completionBlock,methodName: methodName as NSString?)
            }
        }
    }
    /// Perform Post Request.
    ///
    /// - parameter body: parameters to set in Body of the request
    /// - returns: parsed server response via completionBlock
    func performPostRequest(_ body:NSDictionary? , urlString:String ,completionBlock: WSCompletionBlock? ,methodName:String)->(){
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            if isInternetConnectivityAvailable(true)==false {
                return;
            }
            if self.progressIndicatorText != nil{
                showActivityIndicator((self.progressIndicatorText! as NSString) as String);
            }
            let url = URL(string: urlString)

            let requestDetails = "\n\n\n                  HITTING URL\n\n \((url!.absoluteString))\n\n\n                  WITH POST BODY\n\n\(safeString(body, alternate: ""))\n\n"
            logMessage(requestDetails)
            if self.showDebugInformationAboutRequestInNotification {
                showNotification(requestDetails, showOnNavigation: true, showAsError: false, duration: 5)
            }
            

            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            manager.requestSerializer = AFHTTPRequestSerializer()
            self.updateSecurityPolicy(manager)
            self.addCommonInformationInHeader(manager.requestSerializer)
            manager.post(urlString , parameters: body, progress: { (progress) -> Void in
                if self.progressIndicatorText != nil{
                    progressForShowingOnActivityIndicator = progress
                }
            }, success: { (urlSessionDataTask, responseObject) -> Void in
                self.verifyServerResponse(responseObject , error: nil, completionBlock: completionBlock,methodName: methodName as NSString?)
            }) { (urlSessionDataTask, error) -> Void in
                self.verifyServerResponse(nil, error: error as Error as NSError?, completionBlock: completionBlock,methodName: methodName as NSString?)
            }
        }
    }
    /// Perform Multipart Post Request.
    ///
    /// - parameter body: parameters to set in Body of the request
    /// - returns: parsed server response via completionBlock
    func performMultipartPostRequest(_ body:NSDictionary? , urlString:NSString? , constructBody:((AFMultipartFormData) -> Void)?,completionBlock: @escaping WSCompletionBlock ,methodName:NSString?)->(){
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            if isInternetConnectivityAvailable(true)==false {
                return;
            }
            if self.progressIndicatorText != nil{
                showActivityIndicator((self.progressIndicatorText! as NSString) as String);
            }
            let url = URL(string: urlString as! String)
            
            let requestDetails = "\n\n\n                  HITTING URL\n\n \((url!.absoluteString))\n\n\n                  WITH POST BODY\n\n\(safeString(body, alternate: ""))\n\n"
            logMessage(requestDetails)
            if self.showDebugInformationAboutRequestInNotification {
                showNotification(requestDetails, showOnNavigation: true, showAsError: false, duration: 5)
            }

            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            manager.requestSerializer = AFHTTPRequestSerializer()
            self.updateSecurityPolicy(manager)
            self.addCommonInformationInHeader(manager.requestSerializer)
            manager.post(urlString as! String, parameters: body, constructingBodyWith: constructBody, progress: { (progress) -> Void in
                if self.progressIndicatorText != nil{
                    progressForShowingOnActivityIndicator = progress
                }
            }, success: { (urlSessionDataTask, responseObject) -> Void in
                self.verifyServerResponse(responseObject , error: nil, completionBlock: completionBlock,methodName: methodName)
            }) { (urlSessionDataTask, error) -> Void in
                self.verifyServerResponse(nil, error: error as Error as NSError?, completionBlock: completionBlock,methodName: methodName)
            }
        }
        
    }
    
    /// Add commonly used parameters to all request.
    ///
    /// - parameter information: pass the dictionary object here that you created to hold parameters required. This function will add commonly used parameter into it.
    func addCommonInformation(_ information:NSMutableDictionary?)->(){
        if attachCommonUserDetails {
        }
        if attachCommonDeviceDetails {
            copyData("\(getDeviceOperationSystem())" , destinationDictionary: information, destinationKey: "mos", methodName: #function)
            copyData("\(UIDevice.systemVersion())" , destinationDictionary: information, destinationKey: "version", methodName: #function)
            if isNotNull (ez.appVersion){
                copyData("\(ez.appVersion!)" , destinationDictionary: information, destinationKey: "appver", methodName: #function)
            }
        }
    }
    func addCommonInformationInHeader(_ requestSerialiser:AFHTTPRequestSerializer?)->(){
    }
    /// To display server not responding message via notification banner.
    func showServerNotRespondingMessage(){
        DispatchQueue.main.async {
            let showMessage = false
            if showMessage {
                showNotification((MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY as NSString) as String, showOnNavigation: false, showAsError: true)
            }
        }
    }
    /// To check wether the server operation succeeded or not.
    /// - returns: bool
    func isSuccess(_ response:NSDictionary?)->(Bool){
        if response != nil{
            if "\(response?.object(forKey: ServerCommunicationConstants.RESPONSE_CODE_KEY))".isEqual(ServerCommunicationConstants.RESPONSE_CODE_SUCCESS_VALUE){
                return true
            }
        }
        return false
    }
    /// To check wether the server operation failed or not.
    /// - returns: bool
    func isFailure(_ response:NSDictionary?)->(Bool){
        if response != nil{
            if "\(response?.object(forKey: ServerCommunicationConstants.RESPONSE_CODE_KEY))".isEqual(ServerCommunicationConstants.RESPONSE_CODE_FAILURE_VALUE){
                return true
            }
        }
        return false
    }
    /// To verify the server response received and perform action on basis of that.
    /// - parameter response: data received from server in the form of NSData
    func verifyServerResponse(_ response:Any?,error:NSError?,completionBlock: WSCompletionBlock?,methodName:NSString?)->(){
        if responseErrorOption == nil {
            responseErrorOption = ResponseErrorOption.showErrorResponseWithUsingNotification
        }
        if progressIndicatorText != nil{
            hideActivityIndicator();
        }
        if error != nil {
            if responseErrorOption != ResponseErrorOption.dontShowErrorResponseMessage {
                showServerNotRespondingMessage()
            }
            printErrorMessage(error, methodName: #function)
            DispatchQueue.main.async(execute: {
                completionBlock!(nil)
            })
        }
        else if response != nil {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                let responseDictionary = parsedJsonFrom(response as? NSData as Data?,methodName: methodName!)
                if (isNotNull(responseDictionary) && responseDictionary is NSDictionary) {
                    if self.isSuccess(responseDictionary as! NSDictionary?){
                        if self.showSuccessResponseMessage {
                            var successMessage : NSString?
                            if (responseDictionary?.object(forKey: ServerCommunicationConstants.RESPONSE_MESSAGE_KEY) != nil) {
                                if (responseDictionary?.object(forKey: ServerCommunicationConstants.RESPONSE_MESSAGE_KEY) is String) {
                                    successMessage = responseDictionary?.object(forKey: ServerCommunicationConstants.RESPONSE_MESSAGE_KEY) as? NSString
                                }else{
                                    successMessage = "Successfull"
                                }
                            }else{
                                successMessage = "Successfull"
                            }
                            showNotification("👍🏻 \(successMessage!)", showOnNavigation: false, showAsError: false)
                        }
                        DispatchQueue.main.async(execute: {
                            completionBlock!(responseDictionary as? NSDictionary)
                        })
                    }
                    else if self.isFailure(responseDictionary as! NSDictionary?){
                        var errorMessage : NSString?
                        if (responseDictionary?.object(forKey: ServerCommunicationConstants.RESPONSE_MESSAGE_KEY) != nil) {
                            if (responseDictionary?.object(forKey: ServerCommunicationConstants.RESPONSE_MESSAGE_KEY) is NSString) {
                                
                                errorMessage = responseDictionary?.object(forKey: ServerCommunicationConstants.RESPONSE_MESSAGE_KEY) as? NSString
                            }else{
                                errorMessage = responseDictionary?.description as NSString?
                            }
                        }
                        else {
                            errorMessage = MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY as NSString?;
                        }
                        if self.responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingNotification {
                            showNotification("😦 \(errorMessage!)", showOnNavigation: false, showAsError: true)
                        }
                        else if self.responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingPopUp {
                            showPopupAlertMessage("", message: errorMessage! as String, messageType: .error)
                        }
                        if self.returnFailureResponseAlso {
                            DispatchQueue.main.async(execute: {
                                completionBlock!(responseDictionary as? NSDictionary);
                            })
                        }else{
                            DispatchQueue.main.async(execute: {
                                completionBlock!(nil)
                            })
                        }
                    }
                    else {
                        if self.responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingNotification {
                            showNotification((MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY as NSString) as String, showOnNavigation: false, showAsError: true)
                        }
                        else if self.responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingPopUp {
                            showPopupAlertMessage("", message: MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY , messageType: .error)
                        }
                        if self.returnFailureResponseAlso {
                            DispatchQueue.main.async(execute: {
                                completionBlock!(responseDictionary as? NSDictionary)
                            })
                        }else{
                            DispatchQueue.main.async(execute: {
                                completionBlock!(nil)
                            })
                        }
                    }
                }
                else {
                    if self.responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingNotification {
                        showNotification((MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY as NSString) as String, showOnNavigation: false, showAsError: true)
                    }
                    else if self.responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingPopUp {
                        showPopupAlertMessage("", message: MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY , messageType: .error)
                    }
                    if self.returnFailureUnParsedDataIfParsingFails {
                        DispatchQueue.main.async(execute: {
                            completionBlock!(["failedParsingResponseReceived":NSString(data: response as! Data!,encoding: String.Encoding.utf8.rawValue)!])
                        })
                    }else{
                        DispatchQueue.main.async(execute: {
                            completionBlock!(nil)
                        })
                    }
                }
            }
        }
        else {
            if responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingNotification {
                showNotification((MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY as NSString) as String, showOnNavigation: false, showAsError: true)
            }
            else if responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingPopUp {
                showPopupAlertMessage("", message: MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY , messageType: .error)
            }
            DispatchQueue.main.async(execute: {
                completionBlock!(nil)
            })
        }
    }
}

