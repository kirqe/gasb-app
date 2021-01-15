//
//  TokenError.swift
//  gasb
//
//  Created by Kirill Beletskiy on 08/01/2021.
//  Copyright © 2021 kirqe. All rights reserved.
//

import Foundation

struct TokenError: Codable {
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
    }
}
