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
    
    @IBOutlet weak var authorizedLayer: BoxLayer!
    @IBOutlet weak var unauthorizedLayer: NSStackView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        progressIndicator.startAnimation(self)
        Requests.shared.getToken(email: emailField.stringValue, password: passwordField.stringValue) { (result: Result) in
            switch result {
            case .success(let token):
                DispatchQueue.main.async {
                    if self.keychain.get("accessToken") == nil {
                        self.statusLabel.isHidden = false
                        self.statusLabel.stringValue = "Invalid Email/Password or subscription is expired"
                    } else {
                        self.statusLabel.isHidden = true
                    }
                    self.check_token()
                    self.progressIndicator.stopAnimation(self)
                }
            case .failure(_):
                self.check_token()
                self.progressIndicator.stopAnimation(self)
            }
        }            
    }
    
    @IBAction func useNewCredentialsButtonClicked(_ sender: Any) {
        authorizedLayer.isHidden = true
        unauthorizedLayer.isHidden = false
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        _ = load(fromNIBNamed: "AccessView")
        
        statusLabel.isHidden = true
        check_token()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func check_token() {
        if keychain.get("accessToken") == nil {
            authorizedLayer.isHidden = true
            unauthorizedLayer.isHidden = false
        } else {
            statusLabel.isHidden = true
            authorizedLayer.isHidden = false
            unauthorizedLayer.isHidden = true
        }
    }

}
