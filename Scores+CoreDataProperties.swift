//
//  Scores+CoreDataProperties.swift
//  Your Email
//
//  Created by Antonio Tsai on 06/01/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import CoreData


extension Scores {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Scores> {
        return NSFetchRequest<Scores>(entityName: "Scores");
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var score: Int32

}
