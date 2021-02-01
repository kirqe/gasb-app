//
//  ViewController.swift
//  WorldTime
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2020 AppCoda. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
//    @objc let managedObjectContext: NSManagedObjectContext
//
//    required init?(coder: NSCoder) {
//        self.managedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
//        super.init(coder: coder)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window?.titlebarAppearsTransparent = true
        view.window?.styleMask.remove(.resizable)
        view.window?.styleMask.remove(.miniaturizable)
        view.window?.center()
    }
    
}

