//
//  TableTextField.swift
//  gasb
//
//  Created by Kirill Beletskiy on 26/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa

class TableTextField: NSTextField {
    let managedObjectContext = CoreDataManager.shared.persistentContainer.viewContext
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        
    }

    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        
        do {
            try managedObjectContext.save()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                NotificationCenter.default.post(name: Notification.Name("ViewsRecordsUpdated"), object: nil)
            }
        } catch let error {
            print(error)
        }
        
    }
}
