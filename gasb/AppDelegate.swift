//
//  AppDelegate.swift
//  gasb
//
//  Created by Kirill Beletskiy on 21/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    // vms
    var viewModel: ViewModel?
    
    // menu
    var statusItem: NSStatusItem?
    var menu: NSMenu!
    
    // timers
    var refreshDataTimer: Timer? // main timer
    
    // views and windows
    lazy var manageViewWindow = NSWindow()
//    var viewStatsView: ViewStatsView?
    var views: [ViewStatsView] = []
    var paused = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        viewModel = ViewModel()
        UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
        
        startMainTimer()
        
        menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
    
        configureStatusItem()

        configureMenuItems()
    }
    
    // MARK: - Timers
    func startMainTimer() {
        refreshDataTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateDataForViews), userInfo: nil, repeats: true)
        refreshDataTimer?.fire()
        RunLoop.current.add(refreshDataTimer!, forMode: .common)
    }
    
    func stopMainTimer() {
        refreshDataTimer?.invalidate()
        refreshDataTimer = nil
    }
    
    func startViewTimers() {
        
        
    }
    
    func stopViewTimers() {
    
    }
    
        
    // MARK: - Configure Status Item
    func configureStatusItem() {
        updateStatusData()
        // Status Bar
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.action = #selector(self.statusBarButtonClicked(sender:))
        
        // Status Bar Icon
        let itemImage = NSImage(named: "menubar")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage
        statusItem?.button?.imagePosition = NSControl.ImagePosition.imageLeft
    }
    
    func updateStatusData() {
        // Status Bar Data
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.maximumLineHeight = 9
        paragraphStyle.alignment = .right
        
        let textAttr = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9, weight: NSFont.Weight.ultraLight),
        ]

        var top: [String] = []
        var bot: [String] = []
        
        let items = viewModel?.arrayController.arrangedObjects as! [View]

        for item in items {
            let now = UserDefaults.standard.string(forKey: "now:\(item.id!)") ?? "\u{2010}"
            let day = UserDefaults.standard.string(forKey: "day:\(item.id!)") ?? "\u{2010}"
            top.append(now)
            bot.append(day)
        }

        let row1 = NSAttributedString(string: "\n" + top.joined(separator: " \u{2022} "), attributes: textAttr)
        let row2 = NSAttributedString(string: "\n" + bot.joined(separator: " \u{2022} "), attributes: textAttr)
        
        var rows = NSMutableAttributedString(attributedString: NSAttributedString(string: ""))
        rows.append(row1)
        rows.append(row2)
        
        rows.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, rows.length))
        rows.addAttribute(NSAttributedString.Key.baselineOffset, value: 2.0, range:NSMakeRange(0, rows.length))
        
        statusItem?.button?.attributedTitle = rows
        rows = NSMutableAttributedString(attributedString: NSAttributedString(string: ""))

    }
    
    // MARK: - Configure Menu Items
    func configureMenuItems() {
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(withTitle: "Manage Views", action: #selector(openManageViewsView), keyEquivalent: "")
        
        let pauseBtn = NSMenuItem(title: "Pause", action: #selector(pauseChecking), keyEquivalent: "")
        if paused {
            pauseBtn.title = "Resume"
        }
            
        
        
        

        
        menu?.addItem(pauseBtn)
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(withTitle: "About gasb", action: #selector(openAbout), keyEquivalent: "")
        menu?.addItem(withTitle: "Quit gasb", action: #selector(quitApp), keyEquivalent: "")
    }
    
    
    func updateMenuItems() { // redraw
        
        let items = viewModel?.arrayController.arrangedObjects as! [View]
        
        for viewItem in items {
            if (viewItem.id != nil) && (viewItem.service_email != nil) && (viewItem.now || viewItem.day || viewItem.week || viewItem.month) {
                let menuItem = NSMenuItem()
                
                let vsv = ViewStatsView(frame: NSRect(x: 0.0, y: 0.0, width: 200.0, height: 130), viewItem: viewItem)
                
                
                vsv.startTimer() // view specific timer that just take data from userdefaults every n seconds
                views.append(vsv)
                
                menuItem.view = vsv
                menu?.addItem(menuItem)
                menu?.addItem(NSMenuItem.separator())
            }
        }
        configureMenuItems()
    }
    
    @objc func updateDataForViews() {
        updateStatusData()
        let items = viewModel?.arrayController.arrangedObjects as! [View]
        
        for viewItem in items {
            let vsVM = ViewStatsViewModel(view: viewItem)
            
            if viewItem.now {
                vsVM.update(.now)
            }
            if viewItem.day {
                vsVM.update(.day)
            }
            if viewItem.week {
                vsVM.update(.week)
            }
            if viewItem.month {
                vsVM.update(.month)
            }
//            vsVM.updateValues()
//            NotificationCenter.default.post(name: NSNotification.Name("updatedDataNotification"), object: nil)
        }
    }

    
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        
        if let menu = menu {
            menu.removeAllItems()
            statusItem?.menu = menu // add menu to button...
            
            updateMenuItems()
            statusItem?.button?.performClick(nil) // ...and click
        }
    }

    @objc func menuDidClose(_ menu: NSMenu) {
        views.forEach({ $0.stopTimer() })
        statusItem?.menu = nil // remove menu so button works as before
    }
    



    
    
    // MARK: - Handling clicking on menuItems


    @objc func openManageViewsView() {
        let vc = ViewController()
        vc.view = NSView(frame: NSRect(x: 0.0, y: 0.0, width: 920, height: 230))
        
        if NSApp.windows.contains(manageViewWindow) {
            manageViewWindow.makeKeyAndOrderFront(self)
        } else {
            manageViewWindow = NSWindow(contentViewController: vc)
            let manageViewsView = ManageViewsView()
            manageViewsView.add(toView: vc.view)
            
            manageViewWindow.title = "Manage Views"
            manageViewWindow.makeKeyAndOrderFront(self)
        }
    }
    
    @objc func pauseChecking() {
        paused = !paused
        if paused {
            refreshDataTimer?.invalidate()
            
            statusItem?.button?.attributedTitle = NSAttributedString(string: "paused", attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11, weight: NSFont.Weight.ultraLight)])
            
        } else {
            refreshDataTimer?.fire()
        }
    }
    
    @objc func openAbout() {
        NSApp.orderFrontStandardAboutPanel(self)
    }
    
    @objc func quitApp() {
        NSApp.terminate(self)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "gasb")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
}


