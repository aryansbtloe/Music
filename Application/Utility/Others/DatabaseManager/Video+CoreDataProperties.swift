//
//  Video+CoreDataProperties.swift
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

extension Video {

    @NSManaged var descriptionString: String?
    @NSManaged var id: String?
    @NSManaged var releaseDate: String?
    @NSManaged var source: String?
    @NSManaged var thumbnailUrl: String?
    @NSManaged var title: String?

}
