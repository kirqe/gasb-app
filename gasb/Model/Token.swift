//
//  Token.swift
//  gasb
//
//  Created by Kirill Beletskiy on 06/01/2021.
//  Copyright © 2021 kirqe. All rights reserved.
//

import Foundation

struct Token: Codable {
    let date = Date()
    var accessToken: String?
    var refreshToken: String?
    var expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "token"
        case refreshToken = "refreshToken"
        case expiresIn = "expiresIn"
    }
    
    var isValid: Bool {
        let now = Date()
        let seconds = TimeInterval(expiresIn)
        return now.timeIntervalSince(date) < seconds
    }
}
