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
    lazy var accessViewWindow = NSWindow()
    
    @objc dynamic var canAddView = true
    @objc dynamic var canDeleteView = true
    @objc dynamic var objCount = 0

    
    @IBOutlet weak var viewsTableView: NSTableView!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!

    @IBAction func addButtonClicked(_ sender: NSButton) {
        let view = View(context: viewModel.moc)
        view.name = "My bookstore"
        view.subject = "View"
        view.id = 0
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
 
    @IBOutlet weak var ga3MetricsPopUp: NSPopUpButton!
    @IBOutlet weak var ga4MetricsPopUp: NSPopUpButton!
    
    @IBOutlet weak var subjectPopUp: NSPopUpButton!

    
    @IBAction func didSetGa3Metrics(_ sender: NSButton) {
        if let selectedMetric = ga3MetricsPopUp.selectedItem?.title {
            UserDefaults.standard.set(selectedMetric, forKey: "ga3_metric")
        }
    }
    
    @IBAction func didSetGa4Metrics(_ sender: NSButton) {
        if let selectedMetric = ga4MetricsPopUp.selectedItem?.title {
            UserDefaults.standard.set(selectedMetric, forKey: "ga4_metric")
        }
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
            

            
            let ga3_metric = UserDefaults.standard.string(forKey: "ga3_metric")
            if ga3_metric == nil {
                UserDefaults.standard.set("PageViews", forKey: "ga3_metric")
            }
            
            let ga4_metric = UserDefaults.standard.string(forKey: "ga4_metric")
            if ga4_metric == nil {
                UserDefaults.standard.set("ScreenPageViews", forKey: "ga4_metric")
            }

            ga3MetricsPopUp.removeAllItems()
            ga3MetricsPopUp.addItems(withTitles: ["PageViews", "Sessions", "Users", "NewUsers"])
            ga3MetricsPopUp.selectItem(withTitle: UserDefaults.standard.string(forKey: "ga3_metric") ?? "PageViews")
            
            ga4MetricsPopUp.removeAllItems()
            ga4MetricsPopUp.addItems(withTitles: ["ScreenPageViews", "Sessions", "EngagedSessions", "TotalUsers", "NewUsers"])
            ga4MetricsPopUp.selectItem(withTitle: UserDefaults.standard.string(forKey: "ga4_metric") ?? "ScreenPageViews")
            
        }
  
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "arrangedObjects.@count"){
            self.updateCount()
        }
    }

    func updateCount() {
        objCount = (viewModel.arrayController.arrangedObjects as AnyObject).count
        
        if objCount == 0 {
            canAddView = true
            canDeleteView = false
        } else if objCount >= 1 && objCount < 3 {
            canAddView = true
            canDeleteView = true
        } else {
            canAddView = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func openAuth(_ sender: NSButton) {
        let accessVM = AccessViewModel()
        
        if NSApp.windows.contains(accessViewWindow) {
            accessViewWindow.makeKeyAndOrderFront(self)
        } else {
            let vc = ViewController()
            vc.view = NSView(frame: NSRect(x: 0.0, y: 0.0, width: 330, height: 180))
            accessViewWindow = NSWindow(contentViewController: vc)
            
            let accessView = AccessView(viewModel: accessVM)
            accessView.add(toView: vc.view)
            
            accessViewWindow.title = "Authenticate"
            accessViewWindow.makeKeyAndOrderFront(self)
        }
    }
}
