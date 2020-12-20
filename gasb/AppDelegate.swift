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
    var pingTimer: Timer? // runs evey second to refresh data
    
    // views and windows
    lazy var manageViewWindow = NSWindow()
//    var viewStatsView: ViewStatsView?
    var views: [ViewStatsView] = []
    var paused = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        viewModel = ViewModel()
        var request: NSFetchRequest = View.fetchRequest()
        do {
            try viewModel?.moc.fetch(request)
        } catch {
            print("")
        }
        
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
        pingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateStatusData), userInfo: nil, repeats: true)
        pingTimer?.fire()
        
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
        let itemImage = NSImage(named: "menubar2")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage
        statusItem?.button?.imagePosition = NSControl.ImagePosition.imageLeft
         
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.maximumLineHeight = 9
//        paragraphStyle.alignment = .right
//
//        let textAttr = [
//            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9, weight: NSFont.Weight.ultraLight),
//        ]
//
//        let row1 = NSAttributedString(string: "\n \u{2010}", attributes: textAttr)
//        let row2 = NSAttributedString(string: "\n \u{2010}", attributes: textAttr)
//
//        var rows = NSMutableAttributedString(attributedString: NSAttributedString(string: ""))
//        rows.append(row1)
//        rows.append(row2)
//
//        rows.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, rows.length))
//        rows.addAttribute(NSAttributedString.Key.baselineOffset, value: 2.0, range:NSMakeRange(0, rows.length))
//
//        statusItem?.button?.attributedTitle = rows
    }
    
    @objc func updateStatusData() {
        // Status Bar Data
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.maximumLineHeight = 9
        paragraphStyle.alignment = .justified

        let textAttr = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9, weight: NSFont.Weight.ultraLight),
        ]

        var top: [String] = []
        var bot: [String] = []
        
        let items = viewModel?.arrayController.arrangedObjects as! [View]
        print(items.count)
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
    
}
