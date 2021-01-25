//
//  Response.swift
//  gasb
//
//  Created by Kirill Beletskiy on 24/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Foundation

struct StatusResponse: Codable {
    var term: String?
    var value: Int?
    var updated_at: String?
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case term = "term"
        case value = "value"
        case updated_at = "updated_at"
        case message = "message"
    }
}
