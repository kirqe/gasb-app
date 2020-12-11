//
//  ViewStatsViewModel.swift
//  gasb
//
//  Created by Kirill Beletskiy on 27/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Foundation


enum Kind {
    case now
    case day
    case week
    case month
}


class ViewStatsViewModel {
    let defaults = UserDefaults.standard
//    var viewItem: View
    
    var id: String?
    var service_email: String?
    
    var nowValue: Int?
    var dayValue: Int?
    var weekValue: Int?
    var monthValue: Int?
    
    var counter = 0
    var timer: Timer?
    
    init(view: View) {
//        self.viewItem = viewItem
        
        self.id = view.id
        self.service_email = view.service_email
        

        updateValues()
//       NotificationCenter.default.addObserver(self, selector: #selector(updateValues), name: Notification.Name("updatedDataNotification"), object: nil)
    }

    @objc func updateValues() {
        print("update labels")
        self.nowValue = self.defaults.integer(forKey: "now:\(self.id!)")
        self.dayValue = self.defaults.integer(forKey: "day:\(self.id!)")
        self.weekValue = self.defaults.integer(forKey: "week:\(self.id!)")
        self.monthValue = self.defaults.integer(forKey: "month:\(self.id!)")
    }
    
    func update(_ kind: Kind) {
        print("call api")
        switch kind {
        case .now:
            call_api(term: "now:\(self.id!)", service_email: self.service_email!)
        case .day:
            call_api(term: "day:\(self.id!)", service_email: self.service_email!)
        case .week:
            call_api(term: "week:\(self.id!)", service_email: self.service_email!)
        case .month:
            call_api(term: "month:\(self.id!)", service_email: self.service_email!)
        }
    }
    
    
    fileprivate func call_api(term: String, service_email: String) {
        guard let url = URL(string: "http://localhost:9292/status/\(term)?ce=\(service_email)")
            else {
            print("invalid URL")
            return
        }
 
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                     print(error)
                     return
                 }
            if let data = data {

                if let decodeResponse = try? JSONDecoder().decode(Response.self, from: data) {
                    DispatchQueue.main.async {
                        if let value = decodeResponse.value, let term = decodeResponse.term {
                            print("key: \(term), value: \(value)")
                            self.defaults.set(value, forKey: term)
                        }
                    }
                }
            }
        }).resume()
    }

    func startTimer() {
        print("start timer VSViewModel")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateValues), userInfo: nil, repeats: true)
        timer?.fire()

        RunLoop.current.add(timer!, forMode: .common)
    }

    func stopTimer() {
        print("stop timer VSViewModel")
        timer?.invalidate()
        timer = nil
    }
    
}
