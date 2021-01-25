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
    var viewModel: ViewModel = ViewModel()
    var session = Session()

    // menu
    var statusItem: NSStatusItem?
    var menu: NSMenu!
    
    // timers
    var refreshDataTimer: Timer? // main timer
    var drawTimer: Timer?
    
    // views and windows
    lazy var manageViewWindow = NSWindow()
    lazy var accessViewWindow = NSWindow()
    

    var items: [View] = [] // view items from coreData
    var statsViewModels: [ViewStatsViewModel] = []
    var store: Store = Store() // ["now:12345": 10, "day:12345": 22]
    
    var paused = false
    var menuOpened = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // items = viewModel.arrayController.arrangedObjects as! [View]
        UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
        
        startMainTimer()
        
        menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
    
        configureStatusItem()

        configureMenuItems()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setItems), name: Notification.Name("ViewsRecordsUpdated"), object: nil )
        
        NotificationCenter.default.addObserver(self, selector: #selector(pause), name: Notification.Name("InvalidCredentialsEntered"), object: nil )
        
        NotificationCenter.default.addObserver(self, selector: #selector(resume), name: Notification.Name("ValidCredentialsEntered"), object: nil )

    }
    
    @objc func setItems() {
        statsViewModels.removeAll()
        items = viewModel.arrayController.arrangedObjects as! [View]
        for item in items {
            let statsViewModel = ViewStatsViewModel(view: item, store: store) // pass existing data here?
            statsViewModels.append(statsViewModel)
        }
    }
    
    
    // MARK: - Timers
    func startMainTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setItems() // take views from coreData
            self.updateDataForViews() // fetch new data on initial launch
        }
        
        drawTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateStatusData), userInfo: nil, repeats: true)
        drawTimer?.fire()
        
        refreshDataTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateDataForViews), userInfo: nil, repeats: true)
        refreshDataTimer?.fire()
        
        RunLoop.current.add(refreshDataTimer!, forMode: .common)
    }
        
    // MARK: - Configure Status Item
    func configureStatusItem() {
        updateStatusData()
        // Status Bar
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.action = #selector(self.statusBarButtonClicked(sender:))
        
        // Status Bar Icon
        let itemImage = NSImage(named: "menubar3")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage
        statusItem?.button?.imagePosition = NSControl.ImagePosition.imageLeft
    }
    
    @objc func updateStatusData() {
        // Status Bar Data
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 7
        paragraphStyle.maximumLineHeight = 7
        paragraphStyle.alignment = .right

        let textAttr = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9, weight: NSFont.Weight.ultraLight)
        ]

        var top: [String] = []
        var bot: [String] = []
        
        for item in statsViewModels {
    
            if item.now! || item.day! {
                var now = item.now! ? "\(item.nowValue ?? 0)" : "\u{2010}" //"\(Int.random(in: 1..<1000))" //
                var day = item.day! ? "\(item.dayValue ?? 0)" : "\u{2010}"
                var spacing = now.count > day.count ? now.count : day.count
                                                
                while spacing > now.count {
                    now = "\u{00A0}\u{00A0}\u{00A0}\u{00A0}" + now
                    spacing -= 1
                }
                
                while spacing > day.count {
                    day = "\u{00A0}\u{00A0}\u{00A0}\u{00A0}" + day
                    spacing -= 1
                }
       
                top.append(now)
                bot.append(day)
            }
        }
        
        //                                                                 - • -
        let row1 = NSAttributedString(string: "\n" + top.joined(separator: "\u{00A0}\u{2022}\u{00A0}"), attributes: textAttr)
        let row2 = NSAttributedString(string: "\n" + bot.joined(separator: "\u{00A0}\u{2022}\u{00A0}"), attributes: textAttr)
        
        var rows = NSMutableAttributedString(attributedString: NSAttributedString(string: ""))
        rows.append(row1)
        rows.append(row2)
        
        rows.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, rows.length))
        rows.addAttribute(NSAttributedString.Key.baselineOffset, value: 3.7, range:NSMakeRange(0, rows.length))
        
        statusItem?.button?.attributedTitle = rows
        rows = NSMutableAttributedString(attributedString: NSAttributedString(string: ""))
    }
    
    // MARK: - Configure Menu Items
    func configureMenuItems() {
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(withTitle: "Manage Views", action: #selector(openManageViewsView), keyEquivalent: "")
        
        let pauseBtn = NSMenuItem(title: "Pause", action: #selector(togglePause), keyEquivalent: "")
        if paused {
            pauseBtn.title = "Resume"
        }
            
        menu?.addItem(pauseBtn)
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(withTitle: "Authenticate", action: #selector(openAccessView), keyEquivalent: "")
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(withTitle: "About gasb", action: #selector(openAbout), keyEquivalent: "")
        menu?.addItem(withTitle: "Quit gasb", action: #selector(quitApp), keyEquivalent: "")
    }
    
    
    func updateMenuItems() { // redraw
        for statsViewModel in statsViewModels { // statsViewModels
            let menuItem = NSMenuItem()
            let vsv = ViewStatsView(
                frame: NSRect(x: 0.0, y: 0.0, width: 200.0, height: 130),
                viewModel: statsViewModel
            )
            
            menuItem.view = vsv
            menu?.addItem(menuItem)
            menu?.addItem(NSMenuItem.separator())
        }
        
        configureMenuItems()
    }
    
    @objc func updateDataForViews() {
        updateStatusData()
        print("updateDataForViews")
        if !paused {
            let group = DispatchGroup()
            for statsViewModel in statsViewModels {
                if (!statsViewModel.id.isEmpty) &&
                    (statsViewModel.now! || statsViewModel.day! || statsViewModel.week! || statsViewModel.month!) {
                    
                    for kind in Kind.allCases {
                        group.enter()
                        statsViewModel.updateValue(kind: kind, session: session, store: store) { group.leave() }

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
        if let menu = menu {
            menu.removeAllItems()
            statusItem?.menu = menu // add menu to button...
            
            updateMenuItems()
            statusItem?.button?.performClick(nil) // ...and click
        }
    }

    @objc func menuDidClose(_ menu: NSMenu) {
        menuOpened = false
        statusItem?.menu = nil // remove menu so button works as before
    }

    
    // MARK: - Handling clicking on menuItems


    @objc func openManageViewsView() {
        let vc = ViewController()
        vc.view = NSView(frame: NSRect(x: 0.0, y: 0.0, width: 590, height: 210))
        
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
        statusItem?.button?.attributedTitle = NSAttributedString(string: "paused", attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11, weight: NSFont.Weight.ultraLight)])
        
        refreshDataTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateDataForViews), userInfo: nil, repeats: true)
         refreshDataTimer?.fire()
        
        RunLoop.current.add(refreshDataTimer!, forMode: .common)
        
        paused = false
    }
    
    @objc func togglePause() {
        if paused {
            resume()
        } else {
            pause()
        }
    }
    
    @objc func openAccessView() {
        let vc = ViewController()
        vc.view = NSView(frame: NSRect(x: 0.0, y: 0.0, width: 330, height: 178))

        
        if NSApp.windows.contains(accessViewWindow) {
            accessViewWindow.makeKeyAndOrderFront(self)
        } else {
            accessViewWindow = NSWindow(contentViewController: vc)
            let accessView = AccessView()
            accessView.add(toView: vc.view)
            
            accessViewWindow.title = "Login"
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
