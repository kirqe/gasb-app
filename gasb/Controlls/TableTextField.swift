//
//  TableTextField.swift
//  gasb
//
//  Created by Kirill Beletskiy on 26/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa

class TableTextField: NSTextField {
    let managedObjectContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }

    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        
        do {
            try managedObjectContext.save()
        } catch {
            print("")
        }
    }
    
    
}
