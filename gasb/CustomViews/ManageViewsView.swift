//
//  PreferencesView.swift
//  gasb
//
//  Created by Kirill Beletskiy on 23/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa
import CoreData


class ManageViewsView: NSView, LoadableView{
    var viewModel = ViewModel()
    
    @IBOutlet weak var viewsTableView: NSTableView!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    
    @IBAction func addViewClicked(_ sender: NSButton) {
        let view = View(context: viewModel.moc)
        view.name = "my bookstore"
        view.id = ""
        view.service_email = ""
        view.now = true
        viewModel.arrayController.addObject(view)
        
    }
    
    @IBAction func deleteViewClicked(_ sender: NSButton) {
        viewModel.arrayController.remove(viewModel.arrayController.selectedObjects.first)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)


        if load(fromNIBNamed: "ManageViewsView") {

            viewModel.arrayController.addObserver(self, forKeyPath: "arrangedObjects.@count", options: NSKeyValueObservingOptions.new, context: nil)
            viewsTableView.bind(NSBindingName.content, to: viewModel.arrayController, withKeyPath: "arrangedObjects", options: nil)
            viewsTableView.bind(NSBindingName.selectionIndexes, to: viewModel.arrayController, withKeyPath:"selectionIndexes", options: nil)
            viewsTableView.bind(NSBindingName.sortDescriptors, to: viewModel.arrayController, withKeyPath: "sortDescriptors", options: nil)
            addButton.bind(NSBindingName.enabled, to: viewModel.canAddView, withKeyPath: "self", options: nil)
            deleteButton.bind(NSBindingName.enabled, to: viewModel.canDeleteView, withKeyPath: "self", options: nil)
            
            loadViews()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "arrangedObjects.@count"){
            self.updateCount()
        }
    }

    func updateCount() {
        viewModel.objCount = (viewModel.arrayController.arrangedObjects as AnyObject).count
        let count = viewModel.objCount

        if count == 1 {
            viewModel.canAddView = true
            viewModel.canDeleteView = false
        } else if count > 1 && count < 5 {
            viewModel.canDeleteView = true
        } else {
            viewModel.canAddView = false
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
