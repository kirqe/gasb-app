//
//  PreferencesView.swift
//  gasb
//
//  Created by Kirill Beletskiy on 23/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa
import CoreData


class ManageViewsView: NSView, LoadableView {
    var viewModel = ViewModel()
    
    @IBOutlet weak var viewsTableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    
    @objc dynamic var managedObjectContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @objc dynamic var canAddView = true
    @objc dynamic var canRemoveView = true
    @objc dynamic var objCount = 0

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        if load(fromNIBNamed: "ManageViewsView") {
//            arrayController.addObserver(self, forKeyPath: "arrangedObjects.@count", options: NSKeyValueObservingOptions.new, context: nil)
//            
//            viewsTableView!.bind(NSBindingName.content, to: viewModel.arrayController, withKeyPath: "arrangedObjects", options: nil)
//            viewsTableView!.bind(NSBindingName.selectionIndexes, to: viewModel.arrayController, withKeyPath:"selectionIndexes", options: nil)
//            viewsTableView!.bind(NSBindingName.sortDescriptors, to: viewModel.arrayController, withKeyPath: "sortDescriptors", options: nil)
            
            
            
            loadViews()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "arrangedObjects.@count"){
            self.updateCount()
        }
    }
    
    func updateCount() {
        self.objCount = (self.arrayController.arrangedObjects as AnyObject).count
        let count = self.objCount
        
        if count == 1 {
            self.canAddView = true
            self.canRemoveView = false
        } else if count > 1 && count < 5 {
            self.canRemoveView = true
        } else {
            self.canAddView = false
        }
     
    }

    
    required init?(coder aDecoder: NSCoder) {
//        self.managedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.managedObjectModel
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadViews() {
        print("load table")
    }
}
