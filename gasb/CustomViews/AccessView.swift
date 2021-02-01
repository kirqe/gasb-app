//
//  AccessView.swift
//  gasb
//
//  Created by Kirill Beletskiy on 22/12/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa
import Foundation
import KeychainSwift

class AccessView: NSView, LoadableView{
    var accessViewModel = AccessViewModel()
    let keychain = KeychainSwift()
    
    @IBOutlet weak var emailField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBOutlet weak var authorizedLayer: NSBox!
    @IBOutlet weak var unauthorizedLayer: NSStackView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        progressIndicator.startAnimation(self)
        Session.shared.getToken(email: emailField.stringValue, password: passwordField.stringValue) { (result: Result) in
            switch result {
            case .success(let tokenResponse):
                
                DispatchQueue.main.async {
                    self.check_token()
                    if let message = tokenResponse.message {
                        self.statusLabel.stringValue = message
                    }

                    self.progressIndicator.stopAnimation(self)
                }
            case .failure(_):
                 DispatchQueue.main.async {
                    self.check_token()
                    self.progressIndicator.stopAnimation(self)
                }
            }
        }            
    }
    
    @IBAction func useNewCredentialsButtonClicked(_ sender: Any) {
        self.statusLabel.stringValue = ""
        authorizedLayer.isHidden = true
        unauthorizedLayer.isHidden = false
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        _ = load(fromNIBNamed: "AccessView")
        
        check_token()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func check_token() {
            if keychain.get("accessToken") == nil {
                NotificationCenter.default.post(name: NSNotification.Name("InvalidCredentialsEntered"), object: nil)
                authorizedLayer.isHidden = true
                unauthorizedLayer.isHidden = false
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("ValidCredentialsEntered"), object: nil)
//                statusLabel.isHidden = true
                authorizedLayer.isHidden = false
                unauthorizedLayer.isHidden = true
            }

    }

}

