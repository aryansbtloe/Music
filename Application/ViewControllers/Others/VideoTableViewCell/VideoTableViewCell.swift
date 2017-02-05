//
//  VideoTableViewCell.swift
//  Swan Music
//
//  Created by Alok Singh on 01/07/16.
//  Copyright (c) 2016 Swan Music. All rights reserved.
//

import Foundation
import UIKit

class VideoTableViewCell : UITableViewCell {
    var isInitialisedOnce = false
    
    @IBOutlet var videoImageView : UIImageView!
    @IBOutlet var informationLabel1 : UILabel!
    @IBOutlet var informationLabel2 : UILabel!
    @IBOutlet var informationLabel3 : UILabel!
    @IBOutlet var actionButton : UIButton!
    
    var videoInformation : NSDictionary!
    var video : Video!
    var playListNameInAction : String?
    
    weak var parentVC : UIViewController!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        startupInitialisations()
        updateUserInterfaceOnScreen()
    }
    
    func startupInitialisations(){
        if isInitialisedOnce == false {
            self.selectionStyle = UITableViewCellSelectionStyle.none
            videoImageView.layer.cornerRadius = 2
            videoImageView.layer.masksToBounds = true
        }
        isInitialisedOnce = true
    }
    
    func updateUserInterfaceOnScreen(){
        videoImageView.image = nil
        informationLabel1.text = ""
        informationLabel2.text = ""
        informationLabel3.text = ""
        if isNotNull(videoInformation){
            if let snippet = videoInformation.object(forKey: "snippet") as? NSDictionary{
                if let thumbnails = snippet.object(forKey: "thumbnails") as? NSDictionary{
                    if let medium = thumbnails.object(forKey: "medium") as? NSDictionary{
                        if let url = medium.object(forKey: "url") as? String{
                            videoImageView.sd_setImage(with: url.asNSURL() as URL!)
                        }
                    }
                }
                if let title = snippet.object(forKey: "title") as? String{
                    informationLabel1.text = title
                }
                if let description = snippet.object(forKey: "description") as? String{
                    informationLabel2.text = description
                }
                if let publishedAt = snippet.object(forKey: "publishedAt") as? String{
                    informationLabel3.text = "\(publishedAt.dateValue().since())"
                }
                if let channel = snippet.object(forKey: "channelTitle") as? String{
                    informationLabel3.text = informationLabel3.text! + " by \(channel)"
                }
            }
            if let id = videoInformation.object(forKey: "id") as? NSDictionary{
                if let videoId = id.object(forKey: "videoId") as? String{
                    if isNotNull(playListNameInAction){
                        actionButton.isEnabled = !DatabaseManager.sharedInstance.isVideoInPlaylist(["id":videoId], playListName: self.playListNameInAction!)
                    }else{
                        actionButton.isEnabled = !DatabaseManager.sharedInstance.isVideoInLibrary(["id":videoId])
                    }
                }
            }
        }else if isNotNull(video){
            videoImageView.sd_setImage(with: video.thumbnailUrl!.asNSURL() as URL!)
            informationLabel1.text = video.title
            informationLabel2.text = video.descriptionString
            if let publishedAt = video.releaseDate{
                informationLabel3.text = "\(publishedAt.dateValue().since())"
            }
            if let channel = video.source {
                informationLabel3.text = informationLabel3.text! + " by \(channel)"
            }
            actionButton.isHidden = true
        }
    }
    
    static func getRequiredHeight()->(CGFloat){
        return CGFloat(97.0)
    }
    
    @IBAction func onClickOfActionButton(){
        if isNotNull(videoInformation){
            let information = NSMutableDictionary()
            if let snippet = videoInformation.object(forKey: "snippet") as? NSDictionary{
                if let thumbnails = snippet.object(forKey: "thumbnails") as? NSDictionary{
                    if let medium = thumbnails.object(forKey: "medium") as? NSDictionary{
                        if let url = medium.object(forKey: "url") as? String{
                            copyData(url, destinationDictionary: information, destinationKey: "thumbnailUrl", methodName: #function)
                        }
                    }
                }
                if let title = snippet.object(forKey: "title") as? String{
                    copyData(title, destinationDictionary: information, destinationKey: "title", methodName: #function)
                }
                if let description = snippet.object(forKey: "description") as? String{
                    copyData(description, destinationDictionary: information, destinationKey: "descriptionString", methodName: #function)
                }
                if let publishedAt = snippet.object(forKey: "publishedAt") as? String{
                    copyData(publishedAt, destinationDictionary: information, destinationKey: "releaseDate", methodName: #function)
                }
                if let channel = snippet.object(forKey: "channelTitle") as? String{
                    copyData(channel, destinationDictionary: information, destinationKey: "source", methodName: #function)
                }
                if let id = videoInformation.object(forKey: "id") as? NSDictionary{
                    if let videoId = id.object(forKey: "videoId") as? String{
                        copyData(videoId, destinationDictionary: information, destinationKey: "id", methodName: #function)
                    }
                }
            }
            let myLibraryPlaylist = DatabaseManager.sharedInstance.getMyLibraryPlaylist()
            DatabaseManager.sharedInstance.addVideo(information, playlist: myLibraryPlaylist!)

            if isNotNull(playListNameInAction){
            let playlist = DatabaseManager.sharedInstance.getPlaylist(["name":playListNameInAction!])
                if myLibraryPlaylist!.name != playlist!.name {
                    DatabaseManager.sharedInstance.addVideo(information, playlist: playlist!)
                }
                showNotification("video added to your \(playListNameInAction!)", showOnNavigation: false, showAsError: false)
            }else{
                showNotification("video added to your My Library", showOnNavigation: false, showAsError: false)
            }
            actionButton.isEnabled = false
        }
    }
    
    @IBAction func onClickOfPlayButton(){
        resignKeyboard()
        if (isInternetConnectivityAvailable(true)){
            if isNotNull(videoInformation){
                if let id = videoInformation.object(forKey: "id") as? NSDictionary{
                    if let videoId = id.object(forKey: "videoId") as? String{
                        AppCommonFunctions.sharedInstance.playVideo(videoId,viewController: parentVC)
                    }
                }
            }else if isNotNull(video){
                if let videoId = video.id {
                    AppCommonFunctions.sharedInstance.playVideo(videoId,viewController: parentVC)
                }
            }
        }
    }
    
}
