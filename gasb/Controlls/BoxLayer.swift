//
//  BoxLayer.swift
//  gasb
//
//  Created by Kirill Beletskiy on 26/12/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa

class BoxLayer: NSBox {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        wantsLayer = true
        
        
        // Drawing code here.
    }
    
    override func mouseDown(with event: NSEvent) {

    }
    
    

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
}
