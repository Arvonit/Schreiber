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

        sidebar = NSSplitViewItem(
            sidebarWithViewController: NSHostingController(
                rootView: SidebarView(handler: onNoteGroupSelection)
                    .environment(\.managedObjectContext, dataController.context)
            )
        )
        addSplitViewItem(sidebar)

        notesView = NSSplitViewItem(
            contentListWithViewController: makePlaceholderVC("Select a folder")
        )
        addSplitViewItem(notesView)

        noteEditor = NSSplitViewItem(viewController: makePlaceholderVC(""))
        addSplitViewItem(noteEditor)
    }
        
    func makePlaceholderVC(_ text: String) -> NSViewController {
        let vc = NSViewController()
        let backgroundView = NSView(frame: NSRect(x: 0, y: 0, width: 275, height: 300))
        let label = NSTextField(labelWithString: text)
    
        // backgroundView.wantsLayer = true
        // backgroundView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    
        vc.view = backgroundView
        vc.view.addSubview(label)
    
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
    
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .systemGray
        label.alignment = .center
    
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
    
        return vc
    }
        
    func onNoteGroupSelection(newItem: SidebarItem) {
        let vc: NSViewController
        switch newItem {
        case .group(let noteGroup):
            if noteGroup == .allNotes {
                // All Notes
                // vc = NSHostingController(
                //     rootView: NotesView(handler: onNoteSelection)
                //         .environment(\.managedObjectContext, dataController.context)
                // )
                
                // vc = NotesViewControllerOld(nibName: "NotesView", bundle: nil)
                vc = NotesViewController()
            } else {
                // Trash
                vc = NSHostingController(
                    rootView: TrashView(handler: onNoteSelection)
                        .environment(\.managedObjectContext, dataController.context)
                )
            }
        case .folder(let folderID):
            guard let folder: Folder = self.dataController.getManagedObject(id: folderID)
            else { return }
            
            // Notes in certain folder
            vc = NSHostingController(
                rootView: NotesView(folder: folder, handler: onNoteSelection)
                    .environment(\.managedObjectContext, dataController.context)
            )
        }
        
        removeSplitViewItem(notesView)
        notesView.viewController = vc
        insertSplitViewItem(notesView, at: 1)
        
        // This means there are no notes
        removeSplitViewItem(noteEditor)
        noteEditor.viewController = makePlaceholderVC("")
        insertSplitViewItem(noteEditor, at: 2)
    }
    
    func onNoteSelection(newNote: Note) {
        removeSplitViewItem(noteEditor)
        noteEditor.viewController = NoteEditorController(note: newNote)
        insertSplitViewItem(noteEditor, at: 2)
    }
    
}
