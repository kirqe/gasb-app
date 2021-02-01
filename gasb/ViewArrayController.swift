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
    

    override func removeObject(_ object: Any) {
        super.remove(object)
        do {
            try managedObjectContext?.save()
            NotificationCenter.default.post(name: Notification.Name("ViewsRecordsUpdated"), object: nil, userInfo: nil)
        } catch {
            print("error removing object #ViewArrayController")
        }
    }
    
    func applyChanges() {
        do {
            try managedObjectContext?.save()
            NotificationCenter.default.post(name: Notification.Name("ViewsRecordsUpdated"), object: nil, userInfo: nil)
        } catch {
            print("error removing object #ViewArrayController")
        }
    }
}
