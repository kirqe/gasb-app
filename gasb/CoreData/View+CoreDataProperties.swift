//
//  View+CoreDataProperties.swift
//  gasb
//
//  Created by Kirill Beletskiy on 31/03/2021.
//  Copyright © 2021 kirqe. All rights reserved.
//
//

import Foundation
import CoreData


extension View {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<View> {
        return NSFetchRequest<View>(entityName: "View")
    }

    @NSManaged public var day: Bool
    @NSManaged public var id: Int64
    @NSManaged public var month: Bool
    @NSManaged public var name: String?
    @NSManaged public var now: Bool
    @NSManaged public var week: Bool
    @NSManaged public var subject: String?

}
