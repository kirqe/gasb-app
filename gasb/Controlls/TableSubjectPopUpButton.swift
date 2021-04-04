//
//  TableSubjectPopUpButton.swift
//  gasb
//
//  Created by Kirill Beletskiy on 31/03/2021.
//  Copyright © 2021 kirqe. All rights reserved.
//

import Cocoa

class TableSubjectPopUpButton: NSPopUpButton {
    let managedObjectContext = CoreDataManager.shared.persistentContainer.viewContext
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func didCloseMenu(_ menu: NSMenu, with event: NSEvent?) {
        super.didCloseMenu(menu, with: event)

        do {
            try managedObjectContext.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NotificationCenter.default.post(name: Notification.Name("ViewsRecordsUpdated"), object: nil, userInfo: nil)
            }
            
        } catch let error {
            print(error)
        }
    }
}
