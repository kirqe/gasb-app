//
//  TableCheckbox.swift
//  gasb
//
//  Created by Kirill Beletskiy on 26/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa

class TableCheckbox: NSButton {
    let managedObjectContext = CoreDataManager.shared.persistentContainer.viewContext
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        do {
            try managedObjectContext.save()
        } catch {
            print("")
        }
    }
    
}
