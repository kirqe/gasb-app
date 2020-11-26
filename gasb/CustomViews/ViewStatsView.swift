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
    
    @IBOutlet weak var nowLabel: NSTextField!
    
    @IBOutlet weak var dayLabel: NSTextField!
    
    @IBOutlet weak var weekLabel: NSTextField!
    
    @IBOutlet weak var monthLabel: NSTextField!
    
    var timer: Timer?
    var viewId: String?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _ = load(fromNIBNamed: "ViewStatsView")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func getViewId() {
        viewId = UserDefaults.standard.string(forKey: "viewId")
    }
    
    @objc fileprivate func fetchNewData() {
        // get data from view model
        print("fetchNewData")
    }
    
    func startTimer() {
        fetchNewData()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fetchNewData), userInfo: nil, repeats: true)
        timer?.fire()
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//
//        // Drawing code here.
//    }
    
}
