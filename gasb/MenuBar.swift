//
//  MenuBar.swift
//  gasb
//
//  Created by Kirill Beletskiy on 3/13/21.
//  Copyright © 2021 kirqe. All rights reserved.
//

import Foundation
import Cocoa

public class MenuBar {
    private static var statusItem: NSStatusItem?

    @available(OSX 11.0, *)
    public static var theme: MenuBarTheme {
//        if self.statusItem == nil {
//            self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//            self.statusItem?.button?.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)
//            self.statusItem?.isVisible = false
//        }
        
        if let color = self.getPixelColor() {
            return color.redComponent < 0.20 && color.blueComponent < 0.20 && color.greenComponent < 0.20 ? .light : .dark
        }
        else
        {
            return NSApplication.isDarkMode ? .dark : .light
        }
    }

    @available(OSX 11.0, *)
    public static var tintColor: NSColor {
        return self.theme == .light ? NSColor.black : NSColor.white
  }
    
  // MARK: - Helper
  fileprivate static func getPixelColor() -> NSColor?
  {
     if let image = self.statusItem?.button?.layer?.getBitmapImage() {
        let imageRep = NSBitmapImageRep(data: image.tiffRepresentation!)
            
         if let color = imageRep?.colorAt(x: Int(image.size.width / 2.0), y: Int(image.size.height / 2.0)) {
            return color
         }
     }
        
     return nil
  }
}

public enum MenuBarTheme : String
{
    case light = "light"
    case dark = "dark"
}


public extension NSApplication
{
    @available(OSX 10.14, *)
    class var isDarkMode: Bool
    {
        return NSApplication.shared.appearance?.description.lowercased().contains("dark") ?? false
    }
}

public extension CALayer
{
    func getBitmapImage() -> NSImage
    {
        let btmpImgRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(self.frame.width), pixelsHigh: Int(self.frame.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 32)

        let ctx = NSGraphicsContext(bitmapImageRep: btmpImgRep!)
        let cgContext = ctx!.cgContext
        
        self.render(in: cgContext)
        
        let cgImage = cgContext.makeImage()

        return NSImage(cgImage: cgImage!, size: CGSize(width: self.frame.width, height: self.frame.height))
    }
}
