//
//  viewModel.swift
//  gasb
//
//  Created by Kirill Beletskiy on 24/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa
import Foundation
import CoreData

class ViewModel {

    let arrayController = ViewArrayController()
    let moc = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @objc dynamic var canAddView = true
    @objc dynamic var canDeleteView = true
    @objc dynamic var objCount = 0

    init() {
        arrayController.managedObjectContext = moc
        arrayController.bind(NSBindingName.managedObjectContext, to: moc, withKeyPath: "self", options: nil)
        arrayController.entityName = "View"
        arrayController.automaticallyPreparesContent = true
        arrayController.avoidsEmptySelection = true
        arrayController.preservesSelection = true
        arrayController.selectsInsertedObjects = true
        arrayController.clearsFilterPredicateOnInsertion = true
        arrayController.usesLazyFetching = false
        arrayController.fetch(nil)
    }

}
















//
//    init() {
//        let moc = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        arrayController = NSArrayController()
//        arrayController.managedObjectContext = moc
//        arrayController.bind(NSBindingName.managedObjectContext, to: moc, withKeyPath: "self", options: nil)
//        arrayController.entityName = "View"
//        arrayController.automaticallyPreparesContent = true
//        arrayController.avoidsEmptySelection = true
//        arrayController.preservesSelection = true
//        arrayController.selectsInsertedObjects = true
//        arrayController.clearsFilterPredicateOnInsertion = true
//        arrayController.usesLazyFetching = false
//        arrayController.fetch(nil)
//
////        self.arrayController.bind(NSBindingName.managedObjectContext, to: managedObjectContext, withKeyPath: "self", options: nil)
////        self.arrayController.bind(NSBindingName.managedObjectContext, to: self.managedObjectContext, withKeyPath: "@managedObjectContext", options: nil)
//
//
//    }
