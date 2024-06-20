//
//  NotesViewController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 6/19/24.
//

import Cocoa
import SwiftUI

class NotesViewController: NSViewController {
    
    let dataController = (NSApplication.shared.delegate as! AppDelegate).controller
    let folder: Folder?
    
    var tableView: NSTableView!
    var scrollView: NSScrollView!
    var frc: NSFetchedResultsController<Note>!
    
    init(folder: Folder? = nil) {
        self.folder = folder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))
        // configFRC()
        // configScrollView()
        // configTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configFRC()
        configScrollView()
        configTableView()
    }
    
    func configScrollView() {
        scrollView = NSScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.width, .height]
        view.addSubview(scrollView)
    }
    
    func configTableView() {
        tableView = NSTableView(frame: view.bounds)
        tableView.autoresizingMask = [.width, .height]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil // No header
        tableView.rowSizeStyle = .large
        tableView.usesAutomaticRowHeights = true
        tableView.style = .inset
        tableView.intercellSpacing = NSSize(width: 17, height: 0)
        tableView.gridStyleMask = .solidHorizontalGridLineMask
        
        // Create the table column
        let itemColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "NotesColumn2"))
        itemColumn.width = 208
        itemColumn.minWidth = 40
        itemColumn.maxWidth = 1000
        tableView.addTableColumn(itemColumn)
        
        // Add the table view to the scroll view
        scrollView.documentView = tableView
    }
    
    func configFRC() {
        let request = Note.fetchRequest()
        if let folder = folder {
            request.predicate = NSPredicate(format: "inTrash == false and folder == %@", folder)
        } else {
            request.predicate = NSPredicate(format: "inTrash == false")
        }
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        frc = NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: dataController.context,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
    }
    
}

extension NotesViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = NSUserInterfaceItemIdentifier("NoteCell")
        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSHostingView<NoteCellView> {
            cell.rootView = NoteCellView(note: frc.fetchedObjects![row])
                .padding(10) as! NoteCellView
            return cell
        }
        
        // Create a new NSHostingView with NoteCellView
        let cellView = NoteCellView(note: frc.fetchedObjects![row]).padding(10)
        let hostingView = NSHostingView(rootView: cellView)
        hostingView.identifier = cellIdentifier
        
        return hostingView
    }
    
    // func tableViewSelectionDidChange(_ notification: Notification) {
    //     
    // }
    
    func tableView(_ tableView: NSTableView,
                   rowActionsForRow row: Int,
                   edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        if edge == .trailing {
            let del = NSTableViewRowAction(style: .destructive, title: "Delete") {
                (action, indexPath) in
                guard let results = self.frc.fetchedObjects else { return }
                let note = results[indexPath]
                
                note.inTrash = true
                self.dataController.save()
            }
            del.image = NSImage(systemSymbolName: "trash.fill", accessibilityDescription: nil)
            return [del]
        }
        
        return []
    }
}

extension NotesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
}


extension NotesViewController: NSFetchedResultsControllerDelegate {
    
    // Impementation based on this blog post:
    // https://samwize.com/2018/11/16/guide-to-nsfetchedresultscontroller-with-nstableview-macos/
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath.item], withAnimation: .slideDown)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.removeRows(at: [indexPath.item], withAnimation: .slideUp)
            }
        case .update:
            if let indexPath = indexPath {
                let row = indexPath.item
                for column in 0..<tableView.numberOfColumns {
                    // We need to call reloadData() when updating cells
                    // https://stackoverflow.com/questions/55976212/why-does-nstableview-crash-when-processing-deleted-rows-as-nsfetchedresultscontr
                    tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: column))
                    // if let cell = tableView.view(atColumn: column, row: row, makeIfNecessary: true) as? NSTableCellView {
                        // configureCell(cell: cell, row: row)
                    // }
                }
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.removeRows(at: [indexPath.item], withAnimation: .effectFade)
                tableView.insertRows(at: [newIndexPath.item], withAnimation: .effectFade)
            }
        default:
            fatalError("TableView operation not supported")
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
