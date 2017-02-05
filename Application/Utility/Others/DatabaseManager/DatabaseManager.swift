//
//  DatabaseManager.swift
//  Application
//
//  Created by Alok Singh on 01/07/16.
//  Copyright © 2016 Swan Music. All rights reserved.
//

//MARK: - DatabaseManager : This class handles communication of application with its database (Core Data).

import Foundation
import UIKit
import MagicalRecord
import CoreData

//MARK: - Completion block
typealias DMCompletionBlock = (_ returnedData :AnyObject?) ->()

class DatabaseManager: NSObject{
    
    static let sharedInstance : DatabaseManager = {
        let instance = DatabaseManager()
        return instance
    }()
    
    fileprivate override init() {
        
    }
    var completionBlock: DatabaseManager?
    var managedObjectContext : NSManagedObjectContext?

    func setupCoreDataDatabase() {
        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: self.dbStore())
        #if DEBUG
            MagicalRecord.setLoggingLevel(MagicalRecordLoggingLevel.all)
        #else
            MagicalRecord.setLoggingLevel(MagicalRecordLoggingLevel.error)
        #endif
        self.managedObjectContext = NSManagedObjectContext.mr_default()
    }

    /**
     * Playlist
     */
    func addPlaylist(_ info:NSDictionary)->Bool{
        if isNull(getPlaylist(info)){
            let object = Playlist.mr_createEntity(in: managedObjectContext!)
            let dataToSet = NSMutableDictionary()
            copyData(info, sourceKey: "createdOn", destinationDictionary: dataToSet, destinationKey: "createdOn", methodName:#function)
            copyData(info, sourceKey: "name", destinationDictionary: dataToSet, destinationKey: "name", methodName:#function)
            object?.setValuesForKeys((dataToSet as? [String:AnyObject])!)
            saveChanges()
            return true
        }else{
            return false
        }
    }
    
    func getPlaylist(_ info:NSDictionary)->Playlist?{
        return Playlist.mr_findFirst(byAttribute: "name", withValue: info.object(forKey: "name")!)
    }
    
    func getMyLibraryPlaylist()->Playlist?{
        let playlist = getPlaylist(["name":"My Library"])
        if isNull(playlist){
            addPlaylist(["name":"My Library"])
            return getPlaylist(["name":"My Library"])
        }
        return playlist
    }
    
    func getAllPlaylistNames() -> NSArray {
        let allPlaylist = Playlist.mr_findAll()
        let names = NSMutableArray()
        if isNotNull(allPlaylist){
            for playlist in allPlaylist! {
                if let p = playlist as? Playlist{
                    names.add(p.name!)
                }
            }
        }
        return names
    }
    
    /**
     * Video
     */
    func addVideo(_ info:NSDictionary,playlist:Playlist){
        if isNull(getVideo(info,playlist: playlist)){
            let object = Video.mr_createEntity(in: managedObjectContext!)
            let dataToSet = NSMutableDictionary()
            copyData(info, sourceKey: "descriptionString", destinationDictionary: dataToSet, destinationKey: "descriptionString", methodName:#function)
            copyData(info, sourceKey: "id", destinationDictionary: dataToSet, destinationKey: "id", methodName:#function)
            copyData(info, sourceKey: "releaseDate", destinationDictionary: dataToSet, destinationKey: "releaseDate", methodName:#function)
            copyData(info, sourceKey: "source", destinationDictionary: dataToSet, destinationKey: "source", methodName:#function)
            copyData(info, sourceKey: "title", destinationDictionary: dataToSet, destinationKey: "title", methodName:#function)
            copyData(info, sourceKey: "thumbnailUrl", destinationDictionary: dataToSet, destinationKey: "thumbnailUrl", methodName:#function)
            object?.setValuesForKeys((dataToSet as? [String:AnyObject])!)
            if isNull(playlist.videos){
                playlist.videos = NSOrderedSet()
            }
            playlist.videos = playlist.videos?.addObjectAndReturn(object: object!)
            saveChanges()
        }
    }
    
    func getVideo(_ info:NSDictionary,playlist:Playlist)->Video?{
        if let videos = playlist.videos {
            for v in playlist.videos! {
                if let video = v as? Video{
                    if (video.id as! NSString).isEqual(to: info.object(forKey: "id") as! String){
                        return video
                    }
                }
            }
        }
        return nil
    }
    
    func isVideoInLibrary(_ info:NSDictionary)->Bool{
        return isNotNull(getVideo(info, playlist: getMyLibraryPlaylist()!))
    }
    
    func isVideoInPlaylist(_ info:NSDictionary,playListName:String)->Bool{
        return isNotNull(getVideo(info, playlist: getPlaylist(["name":playListName])!))
    }
    
    func searchVideo(_ name:String?,playlist:Playlist)->NSArray{
        if isNotNull(name){
            if playlist.videos?.array != nil {
                return playlist.videos!.filter({ (video) -> Bool in
                    return (video as! Video).title!.lowercased().contains(name!.lowercased().trimmed()) || (video as! Video).descriptionString!.lowercased().contains(name!.lowercased().trimmed())
                }) as NSArray
            }else{
                return NSArray()
            }
        }else{
            if let videos = playlist.videos?.array{
                return videos as NSArray
            }else{
                return NSArray()
            }
        }
    }
    
    /**
     * Common Database Operations
     */
    
    func dbStore() -> String {
        return "\(self.bundleID()).sqlite"
    }
    
    func bundleID() -> String {
        return Bundle.main.bundleIdentifier!
    }
    
    func resetDatabase(){
        Playlist.mr_truncateAll()
        Video.mr_truncateAll()
        CacheManager.sharedInstance.resetDatabase()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        saveChanges()
        setDeviceToken("PUSH+NOTIFICATION+DEVICE+TOKEN+PLACEHOLDER")
    }
    
    func saveChanges(){
        managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }
    
    func saveChangesAsSoonAsPossible(){
        managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }
    
}

