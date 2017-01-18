//
//  YouTubeHelper.swift
//  Application
//
//  Created by Alok Singh on 01/07/16.
//  Copyright © 2016 Swan Music. All rights reserved.
//

import Foundation
import UIKit

let GOOGLE_API_KEY = "AIzaSyDF5il45pY3-e2H4x3QN7cpWRnZzw7Z7x8"

//MARK: - Completion block
typealias YTHCompletionBlock = (_ returnedData :Any) ->()

class YouTubeHelper: NSObject , UITabBarControllerDelegate
{

    var completionBlock: YTHCompletionBlock?
    
    static let sharedInstance : YouTubeHelper = {
        let instance = YouTubeHelper()
        return instance
    }()
    
    fileprivate override init() {
        
    }

    func canContinue() -> Bool {
        return true
    }
    
    func searchVideos(_ searchText:String,completion:@escaping YTHCompletionBlock) {
        if canContinue(){
            let cacheKey = "searchVideosCache\(searchText)"
            if let videos = CacheManager.sharedInstance.loadObject(cacheKey){
                completion(videos)
            }
            let baseUrl = "https://www.googleapis.com/youtube/v3/search"
            let information = NSMutableDictionary()
            information.setObject("snippet", forKey: "part" as NSCopying)
            information.setObject(searchText, forKey: "q" as NSCopying)
            information.setObject("video", forKey: "type" as NSCopying)
            information.setObject("50", forKey: "maxResults" as NSCopying)
            information.setObject(GOOGLE_API_KEY, forKey: "key" as NSCopying)
            let webService = ServerCommunicationManager()
            webService.responseErrorOption = .dontShowErrorResponseMessage
            webService.returnFailureResponseAlso = true
            webService.performGetRequest(information, urlString: baseUrl, completionBlock: { (responseData) in
                if let responseAsDictionary = responseData as NSDictionary?{
                    if let videos = responseAsDictionary.object(forKey: "items") {
                        CacheManager.sharedInstance.saveObject(videos, identifier: cacheKey)
                        completion(returnedData: videos); return;
                    }else{
                        if let _ = CacheManager.sharedInstance.loadObject(cacheKey){
                            //already we returned some cached videos
                        }else{
                            //no videos were returned
                            completion(returnedData: NSMutableArray())
                        }
                    }
                }
                }, methodName: #function)
        }
    }
    
    func getVideoUrls(_ videoId:String,completion:@escaping YTHCompletionBlock) {
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            if let videoInfo = HCYoutubeParser.h264videos(withYoutubeID: videoId) as NSDictionary?{
                let information = NSMutableDictionary()
                if let hdUrl = videoInfo.object(forKey: "hd720") as? String{
                    information.setObject(hdUrl, forKey: "hd" as NSCopying)
                }
                if let mediumUrl = videoInfo.object(forKey: "medium") as? String{
                    information.setObject(mediumUrl, forKey: "medium" as NSCopying)
                }
                if let smallUrl = videoInfo.object(forKey: "small") as? String{
                    information.setObject(smallUrl, forKey: "small" as NSCopying)
                }
                if let moreInfo = videoInfo.object(forKey: "moreInfo") as? NSDictionary{
                    if let length = moreInfo.object(forKey: "length_seconds") as? String{
                        information.setObject(length, forKey: "length" as NSCopying)
                    }
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(information)
                })
            }else{
                let information = NSMutableDictionary()
                information.setObject("https://www.youtube.com/watch?v=\(videoId)", forKey: "youTubeLink" as NSCopying)
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(information)
                })
            }
        })
    }
}
