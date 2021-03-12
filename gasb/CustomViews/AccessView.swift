//
//  AccessView.swift
//  gasb
//
//  Created by Kirill Beletskiy on 22/12/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa
import Foundation

class AccessView: NSView, LoadableView{
    var viewModel: AccessViewModel!
    
    @IBOutlet weak var emailField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        self.progressIndicator.startAnimation(self)
        
        viewModel.logIn(email: emailField.stringValue, password: passwordField.stringValue) { message in
            DispatchQueue.main.async {
                self.statusLabel.stringValue = message
                self.progressIndicator.stopAnimation(self)
            }
        }
    }
    
    init(viewModel: AccessViewModel) {
        super.init(frame: NSRect())
        self.viewModel = viewModel
        
        _ = load(fromNIBNamed: "AccessView")
        
        self.statusLabel.stringValue = viewModel.isAuthenticated ? viewModel.successMessage : ""
        
        
        viewModel.checkToken()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

