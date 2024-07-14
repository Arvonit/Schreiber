//
//  SidebarCell.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 6/24/24.
//

import Cocoa
import SwiftUI

// This is created just for learning purposes. SwiftUI is far better for this sort of task
// than AppKit
class SidebarCellView: NSTableCellView {
    
}


#Preview {
    // let cell = NSTableCellView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
    // let textField = NSTextField(string: "Test")
    // let imageView = NSImageView(image: NSImage(systemSymbolName: "folder", accessibilityDescription: nil) ?? NSImage())
    // cell.textField = textField
    // cell.imageView = imageView
    // return cell
    
    List {
        Label("Folder", systemImage: "folder")
    }.listStyle(.sidebar)
}
