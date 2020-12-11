//
//  ViewStatsView.swift
//  gasb
//
//  Created by Kirill Beletskiy on 24/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa

class ViewStatsView: NSView, LoadableView {
    
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var nowLabel: NSTextField?
    @IBOutlet weak var dayLabel: NSTextField?
    @IBOutlet weak var weekLabel: NSTextField?
    @IBOutlet weak var monthLabel: NSTextField?
    
    var timer: Timer?
    var viewItem: View?
    var viewStatsViewModel: ViewStatsViewModel?
    var viewHeight: CGFloat!
    
//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//        _ = load(fromNIBNamed: "ViewStatsView")
//    }
    
    init(frame frameRect: NSRect, viewItem: View) {
        super.init(frame: frameRect)
        self.viewItem = viewItem
        
        viewHeight = [
            viewItem.now,
            viewItem.day,
            viewItem.week,
            viewItem.month].reduce(0) {acc, v in !v ? (acc + 25) : acc }

        self.frame = NSRect(x: frameRect.maxX, y: frameRect.maxY, width: frameRect.width, height: frameRect.height - viewHeight)
        
        viewStatsViewModel = ViewStatsViewModel(view: viewItem)
        
        _ = load(fromNIBNamed: "ViewStatsView")
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadLabels), name: Notification.Name("updatedDataNotification"), object: nil)
//        reloadLabels()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showNotification(name: String, views: Int) -> Void {
        let notification = NSUserNotification()
        notification.title = "\(name) got views"
        notification.subtitle = "Property has \(views) active users"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    @objc fileprivate func reloadLabels() {
        // get data from view model
        if let name = viewItem?.name {
            self.name.stringValue = name
        }
        
        if let now = viewItem?.now {
            if !now {
                self.nowLabel?.superview?.removeFromSuperview()
            }
            if let nowLabel = viewStatsViewModel?.nowValue {
                self.nowLabel?.stringValue = "\(nowLabel)"
            }
        }
        
        if let day = viewItem?.day {
            if !day {
                self.dayLabel?.superview?.removeFromSuperview()
            }
            if let dayLabel = viewStatsViewModel?.dayValue {
                self.dayLabel?.stringValue = "\(dayLabel)"
            }
        }
        
        if let week = viewItem?.week {
            if !week {
                self.weekLabel?.superview?.removeFromSuperview()
            }
            if let weekLabel = viewStatsViewModel?.weekValue {
                self.weekLabel?.stringValue = "\(weekLabel)"
            }
        }
        
        if let month = viewItem?.month {
            if !month {
                self.monthLabel?.superview?.removeFromSuperview()
            }
            if let monthValue = viewStatsViewModel?.monthValue {
                self.monthLabel?.stringValue = "\(monthValue)"
            }
        }
        
    }
    
    func startTimer() {
        
        reloadLabels()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(reloadLabels), userInfo: nil, repeats: true)
        timer?.fire()
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
