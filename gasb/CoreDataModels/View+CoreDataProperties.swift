//
//  View+CoreDataProperties.swift
//  gasb
//
//  Created by Kirill Beletskiy on 25/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//
//

import Foundation
import CoreData


extension View {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<View> {
        return NSFetchRequest<View>(entityName: "View")
    }

    @NSManaged public var day: Bool
    @NSManaged public var id: String?
    @NSManaged public var month: Bool
    @NSManaged public var name: String?
    @NSManaged public var now: Bool
    @NSManaged public var service_email: String?
    @NSManaged public var week: Bool

}
