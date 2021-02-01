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
    
    @objc dynamic var canAddView = true
    @objc dynamic var canDeleteView = true
    @objc dynamic var objCount = 0
    
    @IBOutlet weak var viewsTableView: NSTableView!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    
    @IBAction func addButtonClicked(_ sender: NSButton) {
        let view = View(context: viewModel.moc)
        view.name = "my bookstore"
        view.id = ""
        view.now = true
        view.day = true
        viewModel.arrayController.addObject(view)
    }
    
    @IBAction func deleteButtonClicked(_ sender: NSButton) {
        if let selectedObject = viewModel.arrayController.selectedObjects.first {
            viewModel.arrayController.removeObject(selectedObject)            
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: NSButton) {
        viewModel.arrayController.applyChanges()
        self.window?.close()
    }
    
    @IBOutlet weak var usersMetricsRadio: NSButton!
    @IBOutlet weak var sessionsMetricsRadio: NSButton!
    @IBOutlet weak var pageViewsMetricsRadio: NSButton!
    

    @IBAction func setMetrics(_ sender: NSButton) {
        UserDefaults.standard.set(sender.title, forKey: "metric")
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        if load(fromNIBNamed: "ManageViewsView") {

            viewModel.arrayController.addObserver(self, forKeyPath: "arrangedObjects.@count", options: NSKeyValueObservingOptions.new, context: nil)
            viewsTableView.bind(NSBindingName.content, to: viewModel.arrayController, withKeyPath: "arrangedObjects", options: nil)
            viewsTableView.bind(NSBindingName.selectionIndexes, to: viewModel.arrayController, withKeyPath:"selectionIndexes", options: nil)
            viewsTableView.bind(NSBindingName.sortDescriptors, to: viewModel.arrayController, withKeyPath: "sortDescriptors", options: nil)
            addButton.bind(NSBindingName.enabled, to: self, withKeyPath: "canAddView", options: nil)
            deleteButton.bind(NSBindingName.enabled, to: self, withKeyPath: "canDeleteView", options: nil)
            
            let metrics = [usersMetricsRadio, sessionsMetricsRadio, pageViewsMetricsRadio]
            
            var metric = UserDefaults.standard.string(forKey: "metric")
            if metric == nil {
                UserDefaults.standard.set("Sessions", forKey: "metric")
                metric = "Sessions"
            }
            
            metrics.forEach{
                if $0?.title == metric {
                    $0!.state = .on
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "arrangedObjects.@count"){
            self.updateCount()
        }
    }

    func updateCount() {
        objCount = (viewModel.arrayController.arrangedObjects as AnyObject).count
        
        if objCount == 1 {
            canAddView = true
            canDeleteView = false
        } else if objCount > 1 && objCount < 3 {
            canAddView = true
            canDeleteView = true
        } else {
            canAddView = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
