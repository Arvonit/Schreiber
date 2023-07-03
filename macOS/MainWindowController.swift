//
//  MainWindowController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 6/18/23.
//

import Cocoa
import SwiftUI

class MainWindowController: NSWindowController {
    
    var dataController = (NSApplication.shared.delegate as! AppDelegate).controller
    
    let mainToolbar = NSToolbar.Identifier("MainToolbar")
    let secondaryDivider = NSToolbarItem.Identifier(rawValue: "SecondaryDivider")
    let addNoteIdentifier = NSToolbarItem.Identifier(rawValue: "AddNote")
    let addFolderIdentifier = NSToolbarItem.Identifier(rawValue: "AddFolder")
        
    override func windowDidLoad() {
        super.windowDidLoad()

        // We need to create our own toolbar
        // Using IB's toolbar can sometimes not load toolbar items on time
        let toolbar = NSToolbar(identifier: mainToolbar)
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        self.window?.toolbar = toolbar
    }
    
    @objc func addNewNote() {
        let _ = Note(folder: nil, context: dataController.context) // Need to put folder, otherwise calls default initializer
        self.dataController.save()
    }
    
    @objc func addNewFolder() {
        let alert = NSAlert()
        alert.messageText = "Add a new folder"
        alert.informativeText = "Enter a name"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 225, height: 24))
        input.bezelStyle = .roundedBezel
        input.placeholderString = "Folder"
        alert.accessoryView = input
        
        alert.beginSheetModal(for: self.window!) { response in
            if response == .alertFirstButtonReturn {
                let name = input.stringValue
                let _ = Folder(name: name, context: self.dataController.context)
                self.dataController.save()
            }
        }
    }
    
}


extension MainWindowController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .flexibleSpace,
            self.addFolderIdentifier,
            .sidebarTrackingSeparator,
            .toggleSidebar,
            self.addNoteIdentifier,
            self.secondaryDivider,
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .flexibleSpace,
            self.addFolderIdentifier,
            .sidebarTrackingSeparator,
            .toggleSidebar,
            self.addNoteIdentifier,
            self.secondaryDivider,
        ]
    }

    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if let splitView = (self.contentViewController as? NSSplitViewController)?.splitView {
            if itemIdentifier == addNoteIdentifier {
                let item = NSToolbarItem(itemIdentifier: itemIdentifier)
                let button = NSButton(image: NSImage(systemSymbolName: "square.and.pencil",
                                                     accessibilityDescription: "Add")!,
                                      target: self,
                                      action: #selector(addNewNote))
                button.bezelStyle = NSButton.BezelStyle.texturedRounded
                item.tag = 2
                item.view = button
                
                let menuItem = NSMenuItem()
                menuItem.submenu = nil
                menuItem.title = "Add"

                item.menuFormRepresentation = menuItem
                
                
                return item
            }
            
            if itemIdentifier == addFolderIdentifier {
                let item = NSToolbarItem(itemIdentifier: itemIdentifier)
                let button = NSButton(image: NSImage(systemSymbolName: "plus",
                                                     accessibilityDescription: "Add")!,
                                      target: self,
                                      action: #selector(addNewFolder))
                button.bezelStyle = NSButton.BezelStyle.texturedRounded
                item.tag = 1
                item.view = button
                
                let menuItem = NSMenuItem()
                menuItem.submenu = nil
                menuItem.title = "Add"

                item.menuFormRepresentation = menuItem

                
                return item
            }


            // You must implement this for custom separator identifiers, to connect the separator with a split view divider
            if itemIdentifier == secondaryDivider {
                return NSTrackingSeparatorToolbarItem(identifier: itemIdentifier, splitView: splitView, dividerIndex: 1)
            }
        }
        return nil
    }
}
