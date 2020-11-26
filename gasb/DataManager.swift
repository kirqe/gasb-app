//
//  DataManager.swift
//  gasb
//
//  Created by Kirill Beletskiy on 25/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    
    func addView() {
        let view = View(context: managedObjectContext)
        view.name = "something"
        view.id = "123123"
        try? managedObjectContext.save()
    }
    
    func loadViews() {
        
    }
}
