//
//  MainWindowController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 6/18/23.
//

import Cocoa

// private extension NSToolbarItem.Identifier {
//     static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
//     static let itemListTrackingSeparator2 = NSToolbarItem.Identifier("ItemListTrackingSeparator2")
// }

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var view: NSView!
    
    // Dangerous convenience alias so you can access the NSSplitViewController and manipulate it later on
    private var splitViewController: MainViewController! {
        contentViewController as? MainViewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        // toolbar.delegate = self
        // toolbar.insertItem(withItemIdentifier: .itemListTrackingSeparator, at: 0)
    }
    
}

// extension MainWindowController: NSToolbarDelegate {
//     func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
//         switch itemIdentifier {
//         case .itemListTrackingSeparator:
//             if ((splitViewController) != nil) {
//                 return NSTrackingSeparatorToolbarItem(identifier: .itemListTrackingSeparator, splitView: splitViewController.splitView, dividerIndex: 1)
//             } else {
//                 return nil
//             }
//         default:
//             return nil
//         }
//     }
// }
