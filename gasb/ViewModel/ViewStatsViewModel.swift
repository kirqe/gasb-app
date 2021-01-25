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
    
    var nowValue: Int? {
        didSet {
            valueDidUpdate(key: "now:\(self.id)", value: self.nowValue ?? 0)
        }
    }
    var dayValue: Int? {
        didSet {
            valueDidUpdate(key: "day:\(self.id)", value: self.dayValue ?? 0)
        }
    }
    var weekValue: Int? {
        didSet {
            valueDidUpdate(key: "week:\(self.id)", value: self.weekValue ?? 0)
        }
    }
    var monthValue: Int? {
        didSet {
            valueDidUpdate(key: "month:\(self.id)", value: self.monthValue ?? 0)
        }
    }
    
    var maxLength: Int = 10
    
    
    // show or hide certain fields
    var now: Bool?
    var day: Bool?
    var week: Bool?
    var month: Bool?
    
    
    init(view: View, store: Store) {
        self.view = view
        self.id = view.id ?? ""
        
        self.now = view.now
        self.day = view.day
        self.week = view.week
        self.month = view.month
        
        self.nowValue = store.get(key: "now:\(self.id)")
        self.dayValue = store.get(key: "day:\(self.id)")
        self.weekValue = store.get(key: "week:\(self.id)")
        self.monthValue = store.get(key: "month:\(self.id)")
    }
    
    private func valueDidUpdate(key: String, value: Int) {

        
        print("call valueDidUpdate")
        NotificationCenter.default.post(name: NSNotification.Name("ViewStatsVMValuesUpdated"), object: nil, userInfo: [key: value])
    }
    
    func updateValue(kind: Kind, session: Session, store: Store, completion: @escaping() -> ()) {
        let term = kind.rawValue + ":" + self.id
        
        var metric = UserDefaults.standard.string(forKey: "metric")
        if metric == nil {
            metric = "sessions"
        }
        session.makeRequest(url: "http://localhost:9292/api/status/\(term)/\(metric!)") { object in
            if let value = object.value, let term = object.term  {
                print("key: \(term), value: \(value)")
                store.set(key: term, value: value)
                            
                self.reloadValuesFrom(store: store)
                            
             }
            completion()
        }
    }
    
    func reloadValuesFrom(store: Store) {
        self.nowValue = store.get(key: "now:\(self.id)")
        self.dayValue = store.get(key: "day:\(self.id)")
        self.weekValue = store.get(key: "week:\(self.id)")
        self.monthValue = store.get(key: "month:\(self.id)")
    }
}


