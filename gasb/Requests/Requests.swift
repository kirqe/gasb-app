//
//  Requests.swift
//  gasb
//
//  Created by Kirill Beletskiy on 07/01/2021.
//  Copyright © 2021 kirqe. All rights reserved.
//

import Foundation
import KeychainSwift

class Requests {
    static var shared = Requests()
    var keys: NSDictionary?
    var baseUrl: String?
    let keychain = KeychainSwift()
    
    init() {

        if let path = Bundle.main.path(forResource: "App", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            baseUrl = dict["BASE_URL"] as? String
        }
    }
    
//    func getStatusOf(term: String, completion: @escaping(StatusResponse) -> ()) {
//        dataRequest(with: "\(baseUrl!)/api/\(term)", httpMethod: "GET", objectType: StatusResponse.self) { (result: Result) in
//            switch result {
//            case .success(let object):
//                if let value = object.value, let term = object.term  {
//                  completion(object)
//                }
//                
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }

    func getToken(email: String, password: String, completion: @escaping(Result<Token>) -> Void) {
        let httpBody = "{\"email\": \"\(email)\", \"password\": \"\(password)\"}"
        
        dataRequest(with: "\(baseUrl!)/api/auth", httpMethod: "POST", httpBody: httpBody, objectType: Token.self) { (result: Result) in
            switch result {
            case .success(let object):

                if let accessToken = object.accessToken, let refreshToken = object.refreshToken {
                    self.keychain.set(email, forKey: "email")
                    self.keychain.set(password, forKey: "password")
                    self.keychain.set(accessToken, forKey: "accessToken")
                    self.keychain.set(refreshToken, forKey: "refreshToken")
                } else {
                    self.keychain.delete("email")
                    self.keychain.delete("password")
                    self.keychain.delete("accessToken")
                    self.keychain.delete("refreshToken")
                }
                completion(Result.success(object))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

    func getToken(refreshToken: String, completion: @escaping(Result<Token>) -> Void) {
        let httpBody = "{\"rt\": \"\(refreshToken)\"}"
        
        dataRequest(with: "\(baseUrl!)/api/auth", httpMethod: "POST", httpBody: httpBody, objectType: Token.self) { (result: Result) in
            switch result {
            case .success(let object):

                if let accessToken = object.accessToken, let refreshToken = object.refreshToken {
                    self.keychain.set(accessToken, forKey: "accessToken")
                    self.keychain.set(refreshToken, forKey: "refreshToken")
                    
                } else {
                    self.keychain.delete("accessToken")
                    self.keychain.delete("refreshToken")
                }
                completion(Result.success(object))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

}

