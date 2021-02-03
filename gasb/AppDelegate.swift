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
    var viewModel: ViewModel = ViewModel()

    // menu
    var statusItem: NSStatusItem?
    var menu: NSMenu!
    
    // timers
    var refreshDataTimer: Timer? // main timer
    
    // views and windows
    lazy var manageViewWindow = NSWindow()
    lazy var accessViewWindow = NSWindow()
    
    var items: [View] = [] // view items from coreData
    var statsViewModels: [ViewStatsViewModel] = [] // for menu views
    var store: Store = Store() // ["now:12345": 10, "day:12345": 22]
    
    var paused = false
    var menuOpened = false
    var iconOnly = false // show only icon in menubar
    
    var iconWidth: CGFloat = CGFloat(30)
    var statusWidth: CGFloat = CGFloat(0)
    var stack: NSStackView?

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // items = viewModel.arrayController.arrangedObjects as! [View]

        UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
        
        startMainTimer()
        
        menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
    
        configureStatusItem()
//        configureMenuItems()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setItems),
                                               name: Notification.Name("ViewsRecordsUpdated"), object: nil )
        
        NotificationCenter.default.addObserver(self, selector: #selector(pause),
                                               name: Notification.Name("InvalidCredentialsEntered"), object: nil )
        
        NotificationCenter.default.addObserver(self, selector: #selector(resume),
                                               name: Notification.Name("ValidCredentialsEntered"), object: nil )
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatusItemWidth),
                                               name: Notification.Name("StatusItemWidthUpdated"), object: nil )
    }

    @objc func setItems() {
        statsViewModels.removeAll()
        
        items = viewModel.arrayController.arrangedObjects as! [View]
        for item in items {
            statsViewModels.append(ViewStatsViewModel(view: item, store: store))
        }
        if !paused && !iconOnly {
            configureStatusItem()
        }
    }
    
    
    // MARK: - Timers
    func startMainTimer() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setItems() // take views from coreData
            self.updateDataForViews() // fetch new data on initial launch
        }

        refreshDataTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateDataForViews), userInfo: nil, repeats: true)
        refreshDataTimer?.fire()
        
        RunLoop.current.add(refreshDataTimer!, forMode: .common)
    }
    
    @objc func updateStatusItemWidth() {
        if paused || iconOnly {
            statusItem?.button?.constraints.forEach {$0.isActive = false}
            statusItem?.length = iconWidth
        } else {
            statusItem?.button?.constraints.forEach {$0.isActive = true}
            statusWidth = statusItem?.length ?? iconWidth
            
            let newWidth: CGFloat = statusItem?.button?.subviews.reduce(iconWidth, { x, y in
                x + y.frame.width
            }) ?? iconWidth
            
            
            if newWidth > statusItem!.length {
                statusItem?.length += (newWidth - statusItem!.length)
            } else {
                statusItem?.length = newWidth
            }
        }
       
    }
    
    // MARK: - Configure Status Item
    @objc func configureStatusItem() {
        // Status Bar
        var views: [StatusItemSectionView] = []
        
        for item in statsViewModels {
            
            if item.isValid {
                let section = StatusItemSectionView(
                    frame: NSRect(),
                    viewModel: item,
                    statusItem: statusItem!,
                    menu: menu
                )
                
                views.append(section)
                
            }
            
        }

        
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.action = #selector(self.statusBarButtonClicked(sender:))
        
        // Status Bar Icon
        let itemImage = NSImage(named: "menubar3")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage
        statusItem?.button?.imagePosition = NSControl.ImagePosition.imageLeft
        

        stack = NSStackView(views: views)
        stack?.translatesAutoresizingMaskIntoConstraints = false
        
        statusItem?.button?.addSubview(stack!)

        statusItem?.button?.addConstraint(NSLayoutConstraint(item: stack!, attribute: .leading, relatedBy: .equal, toItem: statusItem?.button, attribute: .leading, multiplier: 1, constant: 30))
        
        statusItem?.button?.addConstraint(NSLayoutConstraint(item: stack!, attribute: .trailing, relatedBy: .equal, toItem: statusItem?.button, attribute: .trailing, multiplier: 1, constant: -5))
    }
    
    
    // MARK: - Configure Menu Items
    func configureMenuItems() {
        // draw ViewStatsViews
        
        for item in statsViewModels { // statsViewModels
            if item.isValid {
                let menuItem = NSMenuItem()
                let viewStatsView = ViewStatsView(
                    frame: NSRect(x: 0.0, y: 0.0, width: 220.0, height: 130),
                    viewModel: item
                )
                menuItem.view = viewStatsView
                menu?.addItem(menuItem)
                menu?.addItem(NSMenuItem.separator())
            }
        }
        
        // draw generic elements
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(withTitle: "Manage Views", action: #selector(openManageViewsView), keyEquivalent: "")
        
        let pauseStatus = paused ? "Resume" : "Pause"
        let pauseBtn = NSMenuItem(title: pauseStatus, action: #selector(togglePause), keyEquivalent: "")
        menu?.addItem(pauseBtn)
        
        let displayMode = iconOnly ? "Show menu stats" : "Hide menu stats"
        let toggleMenuStatusBtn = NSMenuItem(title: displayMode, action: #selector(toggleDisplayMode), keyEquivalent: "")
        toggleMenuStatusBtn.isEnabled = !paused
        menu?.addItem(toggleMenuStatusBtn)
        
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(withTitle: "Auth", action: #selector(openAccessView), keyEquivalent: "")
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(withTitle: "About gasb", action: #selector(openAbout), keyEquivalent: "")
        menu?.addItem(withTitle: "Quit gasb", action: #selector(quitApp), keyEquivalent: "")
    }
    
    @objc func updateDataForViews() {
        if !paused {
            let group = DispatchGroup()
            
            for item in statsViewModels {
                if item.isValid {
                    for kind in Kind.allCases {
                        group.enter()
                        item.updateValue(kind: kind, store: store) { group.leave() }
                    }
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        menuOpened = true
        // toggleInvertColors(on: true)

        if let menu = menu {
            menu.removeAllItems()
            statusItem?.menu = menu // add menu to button...
            configureMenuItems()
//            statusItem?.button?.performClick(nil) // ...and click
        }
    }

    @objc func menuDidClose(_ menu: NSMenu) {
        menuOpened = false
        toggleInvertColors(on: false)
        statusItem?.menu = nil // remove menu so button works as before
    }

    
     @objc func toggleInvertColors(on: Bool) {
        if let stackViews = stack?.views {
            for view in stackViews {
               if let sISV = (view as? StatusItemSectionView) {
                   sISV.clicked = on
                   sISV.darkMenuBar = sISV.isDarkMode()
                   view.needsDisplay = true
               }
            }
        }
    }
 
    // MARK: - Handling clicking on menuItems
    @objc func openManageViewsView() {
        let vc = ViewController()
        vc.view = NSView(frame: NSRect(x: 0.0, y: 0.0, width: 550, height: 210))
        
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
    
    @objc func pause() {
        refreshDataTimer?.invalidate()
        paused = true
    }
    
    @objc func resume() {
        refreshDataTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateDataForViews), userInfo: nil, repeats: true)
        refreshDataTimer?.fire()
        RunLoop.current.add(refreshDataTimer!, forMode: .common)
        
        paused = false
        if !iconOnly {
            configureStatusItem()
        }
            
        updateStatusItemWidth()
    }
    
    @objc func togglePause() {
        paused ? resume() : pause()
        updateStatusItemWidth()
    }
    
    @objc func toggleDisplayMode() {
        iconOnly ? statusNormal() : statusIconOnly()
    }
    
    func statusIconOnly() {
        iconOnly = true
        updateStatusItemWidth()
    }
    
    func statusNormal() {
        iconOnly = false
        updateStatusItemWidth()
        configureStatusItem()
    }
    
    @objc func openAccessView() {
        let accessVM = AccessViewModel()
        
        if NSApp.windows.contains(accessViewWindow) {
            accessViewWindow.makeKeyAndOrderFront(self)
        } else {
            let vc = ViewController()
            vc.view = NSView(frame: NSRect(x: 0.0, y: 0.0, width: 330, height: 178))
            accessViewWindow = NSWindow(contentViewController: vc)
            
            let accessView = AccessView(viewModel: accessVM)
            
            accessView.add(toView: vc.view)
            
            accessViewWindow.title = "Auth"
            accessViewWindow.makeKeyAndOrderFront(self)
        }
    }
    
    @objc func openAbout() {
        NSApp.orderFrontStandardAboutPanel(self)
    }
    
    @objc func quitApp() {
        NSApp.terminate(self)
    }
}

extension NSStatusBarButton {
    open override func mouseDown(with event: NSEvent) {
        if let stackViews = subviews.first?.subviews {
            for view in stackViews {
               if let sISV = (view as? StatusItemSectionView) {
                   sISV.clicked = true
                   sISV.darkMenuBar = sISV.isDarkMode()
                   view.needsDisplay = true
               }

            }
        }
        
        performClick(nil)
        super.mouseDown(with: event)
    }
}
