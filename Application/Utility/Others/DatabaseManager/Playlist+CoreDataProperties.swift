//
//  Playlist+CoreDataProperties.swift
//  Application
//
//  Created by Swan Music on 05/07/16.
//  Copyright © 2016 Swan Music. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Playlist {

    @NSManaged var createdOn: Date?
    @NSManaged var name: String?
    @NSManaged var videos: NSOrderedSet?

}
