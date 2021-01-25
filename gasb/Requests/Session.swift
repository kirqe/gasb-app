//
//  RequestInterceptor.swift
//  gasb
//
//  Created by Kirill Beletskiy on 08/01/2021.
//  Copyright © 2021 kirqe. All rights reserved.
//

import Foundation
import KeychainSwift

class Session {
    let keychain = KeychainSwift()
    
    struct SRequest {
        var url: URL
        var completion: (StatusResponse) -> Void
    }

    private let requestsQueue = DispatchQueue( label: "Session.requestsQueue", attributes: .concurrent)
    private var queuedRequests = Array<SRequest>()
    private var token: Token?
    private var isFetchingToken: Bool = false

    init() {
        fetchAccessToken()
    }

    func makeRequest(url: String, httpBody: Data = Data(), completion: @escaping (StatusResponse) -> Void) {
        let request = SRequest(url: URL(string: url)!, completion: completion)

        if let token = self.token {
            if token.isValid {
                let headers = [
                    "Authorization": "Bearer \(token.accessToken!)",
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ]
                
                dataRequest(with: url, httpMethod: "GET", headers: headers, objectType: StatusResponse.self) { (result: Result) in
                    switch result {
                    case .success(let object):
                        completion(object)
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                if let token = token.refreshToken {
                    self.queueRequest(sRequest: request)
                    if !isFetchingToken {
                        self.refreshToken(using: token)
                    }
                } else {
                    self.queueRequest(sRequest: request)
                    if !isFetchingToken {
                        self.fetchAccessToken()
                    }
                }
            }
        } else {

            
            self.queueRequest(sRequest: request)
            if !isFetchingToken {
                self.fetchAccessToken()
            }
        }
        
    }

    private func fetchAccessToken() { // login
        isFetchingToken = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            print("stopped timer")
            self.isFetchingToken = false
        }

        
        guard let email = keychain.get("email") else { return }
        guard let password = keychain.get("password") else { return }

        Requests.shared.getToken(email: email, password: password) { (result: Result) in
            switch result {
            case .success(let token):
                self.token = token
                self.isFetchingToken = false
                self.processRequests()
            case .failure(_):
                self.isFetchingToken = false
            }
            
        }
    }

    private func refreshToken(using refreshToken: String) {
        isFetchingToken = true
        Requests.shared.getToken(refreshToken: refreshToken) { (result: Result) in
            switch result {
            case .success(let token):
                self.token = token
                self.isFetchingToken = false
                self.processRequests()
            case .failure(_):
                self.isFetchingToken = false
            }
            
        }

    }

    private func queueRequest(sRequest: SRequest) {
        self.queuedRequests.append(sRequest)
    }

    private func processRequests() {
        requestsQueue.async(flags: .barrier) { [weak self] in
            self?.queuedRequests.forEach { (sRequest) in
                self?.makeRequest(url: sRequest.url.absoluteString, completion: sRequest.completion)
            }
        }
        self.queuedRequests.removeAll()
    }
}
