//
//  ViewArrayController.swift
//  gasb
//
//  Created by Kirill Beletskiy on 25/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa
import CoreData

class ViewArrayController:  NSArrayController {
    override func addObject(_ object: Any) {
        super.addObject(object)
        do {
            try managedObjectContext?.save()
        } catch {
            print("error saving object #ViewArrayController")
        }
    }
    
    override func remove(atArrangedObjectIndex index: Int) {
        super.remove(atArrangedObjectIndex: index)
        do {
            try managedObjectContext?.save()
        } catch {
            print("error removing object #ViewArrayController")
        }
    }
}
