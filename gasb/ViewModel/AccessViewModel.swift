//
//  AccessViewModel.swift
//  gasb
//
//  Created by Kirill Beletskiy on 03/02/2021.
//  Copyright © 2021 kirqe. All rights reserved.
//

import Foundation
import KeychainSwift

class AccessViewModel {
    let keychain = KeychainSwift()
    
    var isAuthenticated: Bool {
       keychain.get("accessToken") == nil
    }
    
    var statusMessage: String = ""
    
    var isBeingAuthenticated: Bool = false
    
    init() {
        self.checkToken()
    }
    
    func logIn(email: String, password: String, completion: @escaping(String) -> Void) {
        
        
        if isValidEmail(email) && isValidPassword(password) {
            self.isBeingAuthenticated = true
            
            Session.shared.getToken(email: email, password: password) { (result: Result) in
                switch result {
                case .success(let tokenResponse):
                    if let message = tokenResponse.message {
                        self.statusMessage = message
                    }
                    self.isBeingAuthenticated = false
                    self.checkToken()
                    completion(self.statusMessage)
                case .failure(_):
                    self.statusMessage = "Error connecting to the server"
                    self.checkToken()
                    self.isBeingAuthenticated = false
                    completion(self.statusMessage)
                }
            }
        } else {
            self.statusMessage = "Invalid email format or password is too short"
            self.isBeingAuthenticated = false
            completion(self.statusMessage)
        }
        
    }
    
    func checkToken() {
        DispatchQueue.main.async {
            if self.isAuthenticated {
                NotificationCenter.default.post(name: NSNotification.Name("InvalidCredentialsEntered"), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("ValidCredentialsEntered"), object: nil)
                self.statusMessage = "Success! \nClose this window or authenticate with new account"
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count > 5
    }
}
