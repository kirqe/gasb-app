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

    var viewItem: View?
    var viewModel: ViewStatsViewModel?
    var viewHeight: CGFloat!
    
//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//        _ = load(fromNIBNamed: "ViewStatsView")
//    }
    
    init(frame frameRect: NSRect, viewModel: ViewStatsViewModel) {
        super.init(frame: frameRect)
        
        self.viewModel = viewModel
        self.viewItem = viewModel.view
        guard let viewItem = self.viewItem else { return }
        
        // hide unused labels
        viewHeight = [
            viewItem.now,
            viewItem.day,
            viewItem.week,
            viewItem.month].reduce(0) {acc, v in !v ? (acc + 25) : acc }

        self.frame = NSRect(x: frameRect.maxX, y: frameRect.maxY, width: frameRect.width, height: frameRect.height - viewHeight)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLabels), name: Notification.Name("ViewStatsVMValuesUpdated"), object: nil )
        
        _ = load(fromNIBNamed: "ViewStatsView")
       
        DispatchQueue.main.async {
            if let name = viewItem.name {
                self.name.stringValue = name
            }
        }
        
        reloadLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func showNotification(name: String, views: Int) -> Void {
//        let notification = NSUserNotification()
//        notification.title = "\(name) got views"
//        notification.subtitle = "Property has \(views) active users"
//        notification.soundName = NSUserNotificationDefaultSoundName
//        NSUserNotificationCenter.default.deliver(notification)
//    }
    
    @objc func reloadLabels() {
        print("reload")
        
        
        if let vsVM = self.viewModel {
            DispatchQueue.main.async {
                // NOW
                if let now = vsVM.now {
                    if !now {
                        self.nowLabel?.superview?.removeFromSuperview()
                    }

                    self.nowLabel?.stringValue = "\(vsVM.nowValue ?? 0)"
                }
                
                // DAY
                if let day = vsVM.day {
                    if !day {
                        self.dayLabel?.superview?.removeFromSuperview()
                    }

                    self.dayLabel?.stringValue = "\(vsVM.dayValue ?? 0)"
                }
                
                // WEEK
                if let week = vsVM.week {
                    if !week {
                        self.weekLabel?.superview?.removeFromSuperview()
                    }

                    self.weekLabel?.stringValue = "\(vsVM.weekValue ?? 0)"
                }
                
                // MONTH
                if let month = vsVM.month {
                    if !month {
                        self.monthLabel?.superview?.removeFromSuperview()
                    }

                    self.monthLabel?.stringValue = "\(vsVM.monthValue ?? 0)"
                }
                
            }
        }
    }

}
