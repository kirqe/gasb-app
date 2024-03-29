//
//  StatusItemSectionView.swift
//  gasb
//
//  Created by Kirill Beletskiy on 26/01/2021.
//  Copyright © 2021 kirqe. All rights reserved.
//

import Cocoa

class StatusItemSectionView: NSView, LoadableView {
    @IBOutlet weak var preTop: NSTextField!
    @IBOutlet weak var preBot: NSTextField!
    
    @IBOutlet weak var topValue: NSTextField!
    @IBOutlet weak var botValue: NSTextField!
    
    var statusItem: NSStatusItem?
    var viewItem: View?
    var viewModel: ViewStatsViewModel?
    
    // https://github.com/Tao93/NetTool/blob/9c41248a9378ac1f3401d47a91e43e24b524804c/NeTool/StatusBarView.swift
    var clicked: Bool = false
    var darkMenuBar: Bool = false
  
    
    init(frame frameRect: NSRect, viewModel: ViewStatsViewModel) {
        super.init(frame: frameRect)
        
        self.viewModel = viewModel
        self.viewItem = viewModel.view
        darkMenuBar = isDarkMode()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadLabels), name: Notification.Name("ViewStatsVMValuesUpdated"), object: nil )
        
        _ = load(fromNIBNamed: "StatusItemSectionView")

       reloadLabels()
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(change), name:NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
        
//        var refreshDataTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(reloadLabels), userInfo: nil, repeats: true)
//        refreshDataTimer.fire()
//        RunLoop.current.add(refreshDataTimer, forMode: .common)
    }
    
    func isDarkMode() -> Bool {
        let dict = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
        if let style:AnyObject = dict!["AppleInterfaceStyle"] as AnyObject? {
            if (style as! String).caseInsensitiveCompare("dark") == ComparisonResult.orderedSame {
                return true
            }
        }
        return false
    }

    @objc func change() {
        darkMenuBar = isDarkMode()
        needsDisplay = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func reloadLabels() {
        // check if enabled
        DispatchQueue.main.async {
            self.topValue?.stringValue = "\(self.viewModel?.nowValue ?? 0)"
            self.botValue?.stringValue = "\(self.viewModel?.dayValue ?? 0)"
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if #available(OSX 11.0, *) {

        } else {
            statusItem?.drawStatusBarBackground(in: dirtyRect, withHighlight: clicked)
            let textColor = (darkMenuBar || clicked) ? NSColor.white : NSColor.black
            self.preTop.textColor = textColor
            self.preBot.textColor = textColor
            self.topValue.textColor = textColor
            self.botValue.textColor = textColor
        }
    }
}

