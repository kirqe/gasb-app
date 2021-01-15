//
//  Store.swift
//  gasb
//
//  Created by Kirill Beletskiy on 11/01/2021.
//  Copyright © 2021 kirqe. All rights reserved.
//

import Foundation

class Store {
    private var storage: [String: Int] = [:]
    
    init() {
        
    }
    
    func all() -> [String: Int] {
        return storage
    }
    
    func get(key: String) -> Int? {
        if let value = storage[key] {
            return value
        }
        return nil
    }
    
    func set(key: String, value: Int) -> Void {
        storage[key] = value
        NotificationCenter.default.post(name: NSNotification.Name("ViewStatsVMValuesUpdated"), object: nil, userInfo: [key: value])
    }
}
