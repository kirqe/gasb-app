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
    lazy var arrayController = NSArrayController()
    @objc dynamic var managedObjectContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @objc dynamic var canAddView = true
    @objc dynamic var canRemoveView = true
    @objc dynamic var objCount = 0


    
    init() {
        
//        self.arrayController.bind(NSBindingName.managedObjectContext, to: managedObjectContext, withKeyPath: "self", options: nil)
//        self.arrayController.bind(NSBindingName.managedObjectContext, to: self.managedObjectContext, withKeyPath: "@managedObjectContext", options: nil)
        
        
    }
}
//viewsTableView!.bind(NSBindingName.sortDescriptors, to: viewModel.arrayController, withKeyPath: "sortDescriptors", options: nil)

