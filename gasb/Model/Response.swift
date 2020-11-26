//
//  Response.swift
//  gasb
//
//  Created by Kirill Beletskiy on 24/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Foundation

struct Response: Codable {
    var term: String?
    var value: Int?
    var updated_at: Date?
}
