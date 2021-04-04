//
//  ViewStatsViewModel.swift
//  gasb
//
//  Created by Kirill Beletskiy on 27/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Foundation
import KeychainSwift

enum Kind: String, CaseIterable {
    case now
    case day
    case week
    case month
}

class ViewStatsViewModel {
    var view: View?
    var id: String
    var subject: String!

    var nowValue: Int? {
        didSet {
            valueDidUpdate(key: "now:\(self.subject.lowercased()):\(self.id):\(self.metric)", value: self.nowValue ?? 0)
        }
    }
    var dayValue: Int? {
        didSet {
            valueDidUpdate(key: "day:\(self.subject.lowercased()):\(self.id):\(self.metric)", value: self.dayValue ?? 0)
        }
    }
    var weekValue: Int? {
        didSet {
            valueDidUpdate(key: "week:\(self.subject.lowercased()):\(self.id):\(self.metric)", value: self.weekValue ?? 0)
        }
    }
    var monthValue: Int? {
        didSet {
            valueDidUpdate(key: "month:\(self.subject.lowercased()):\(self.id):\(self.metric)", value: self.monthValue ?? 0)
        }
    }
    
    var maxLength: Int = 10
    
    var isValid: Bool {
        return (!self.id.isEmpty) && (self.id.count > 3) &&
               (self.now! || self.day! || self.week! || self.month!)
    }
    
    // show or hide certain fields
    var now: Bool?
    var day: Bool?
    var week: Bool?
    var month: Bool?
    
    var metric: String {    
        return (subject == "View") ?
            (UserDefaults.standard.string(forKey: "ga3_metric") ?? "PageViews") :
            (UserDefaults.standard.string(forKey: "ga4_metric") ?? "ScreenPageViews")
    }
    
    
    init(view: View, store: Store) {
        self.view = view
        self.id = "\(view.id)"
        self.subject = view.subject
        
        self.now = view.now
        self.day = view.day
        self.week = view.week
        self.month = view.month
        
        loadValuesFrom(store)
    }
    
    private func valueDidUpdate(key: String, value: Int) {
        NotificationCenter.default.post(name: NSNotification.Name("ViewStatsVMValuesUpdated"), object: nil, userInfo: [key: value])
    }
    
    func updateValue(kind: Kind, store: Store, completion: @escaping() -> ()) {
        let term = kind.rawValue + ":" + self.subject.lowercased() + ":" + self.id + ":" + self.metric
        
        let mirror = Mirror(reflecting: self)
        
//        let kinds = Kind.allCases.map { $0.rawValue }


        
        for case let (label?, value) in mirror.children {
            if label == kind.rawValue {
                if value as! Bool {
                    Session.shared.getStatus(of: term) { object in
                        if let value = object.value, let term = object.term  {
                            // print("key: \(term), value: \(value)")
                            store.set(key: term, value: value)
                            self.loadValuesFrom(store)
                        }
                        completion()
                    }
                }
            }
        }
    }
    
    func loadValuesFrom(_ store: Store) {
        self.nowValue   = store.get(key: "now:\(self.subject.lowercased()):\(self.id):\(self.metric)")
        self.dayValue   = store.get(key: "day:\(self.subject.lowercased()):\(self.id):\(self.metric)")
        self.weekValue  = store.get(key: "week:\(self.subject.lowercased()):\(self.id):\(self.metric)")
        self.monthValue = store.get(key: "month:\(self.subject.lowercased()):\(self.id):\(self.metric)")
    }
}


