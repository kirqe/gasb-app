//
//  CustomTextField.swift
//  menubar
//
//  Created by Kirill Beletskiy on 11/11/2020.
//  Copyright © 2020 kirqe. All rights reserved.
//

import Cocoa

class CustomTextField: NSTextField {

    let fieldBackgroundColor = NSColor(
                                    calibratedHue: 230/360,
                                    saturation: 0.15,
                                    brightness: 0.85,
                                    alpha: 1)
    let fieldBorderColor = NSColor(
                                    calibratedHue: 230/360,
                                    saturation: 0.35,
                                    brightness: 0.50,
                                    alpha: 0.3)
    let fieldTextColor = NSColor(
                                    calibratedHue: 230/360,
                                    saturation: 0.40,
                                    brightness: 0.35,
                                    alpha: 1)
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.wantsLayer = true
//        let textFieldLayer = CALayer()
//        self.layer = textFieldLayer
//        self.layer?.backgroundColor = NSColor(red: 255/255.0, green: 232/255.0, blue: 166/255.0, alpha: 1).cgColor
        self.layer?.borderWidth = 1
        self.layer?.cornerRadius = 5
        self.layer?.borderColor = fieldBorderColor.cgColor
        
        self.textColor = fieldTextColor
        font = NSFont.systemFont(ofSize: 22)
 
       
    }
    

    
}
extension NSTextView {
override open func performKeyEquivalent(with event: NSEvent) -> Bool {
    let commandKey = NSEvent.ModifierFlags.command.rawValue
    let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
    if event.type == NSEvent.EventType.keyDown {
        if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
            switch event.charactersIgnoringModifiers! {
            case "x":
                if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return true }
            case "c":
                if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return true }
            case "v":
                if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return true }
            case "z":
                if NSApp.sendAction(Selector(("undo:")), to:nil, from:self) { return true }
            case "a":
                if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return true }
            default:
                break
            }
        } else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
            if event.charactersIgnoringModifiers == "Z" {
                if NSApp.sendAction(Selector(("redo:")), to:nil, from:self) { return true }
            }
        }
    }
    return super.performKeyEquivalent(with: event)
}
}
