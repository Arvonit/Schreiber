//
//  MainViewController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 6/18/23.
//

import Cocoa
import SwiftUI

class MainViewController: NSSplitViewController {

    var dataController = (NSApplication.shared.delegate as! AppDelegate).controller
    var sidebar: NSSplitViewItem!
    var notesView: NSSplitViewItem!
    var noteEditor: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // sidebar = NSSplitViewItem(
        //     sidebarWithViewController: SidebarViewController(nibName: "SidebarView", bundle: nil)
        // )
        sidebar = NSSplitViewItem(
            sidebarWithViewController: NSHostingController(
                rootView: SidebarView()
                    .environment(\.managedObjectContext, dataController.context)
            )
        )
        addSplitViewItem(sidebar)

        // notesView = NSSplitViewItem(
        //     contentListWithViewController: NotesViewController(nibName: "NotesView", bundle: nil)
        // )
        notesView = NSSplitViewItem(
            contentListWithViewController: NSHostingController(
                rootView: NotesView()
                    .environment(\.managedObjectContext, dataController.context)
            )
        )
        addSplitViewItem(notesView)

        noteEditor = NSSplitViewItem(
            viewController: NoteEditorViewController(nibName: "NoteEditorView", bundle: nil)
        )
        addSplitViewItem(noteEditor)
    }

}
