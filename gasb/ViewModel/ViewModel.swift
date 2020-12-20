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
//    let moc = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let moc = CoreDataManager.shared.persistentContainer.viewContext
    
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
