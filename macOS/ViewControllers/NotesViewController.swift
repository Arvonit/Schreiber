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
    let handler: ((Note) -> Void)?
    
    var tableView: NSTableView!
    var scrollView: NSScrollView!
    var frc: NSFetchedResultsController<Note>!
    
    // Not using this currently becuase animations cannot be customized
    // Delete animation is a fade instead of slide up, which looks off
    // var dataSource: NSTableViewDiffableDataSource<Int, NSManagedObjectID>!
    
    init(folder: Folder? = nil, handler: ((Note) -> Void)? = nil) {
        self.folder = folder
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 560))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configFRC()
        configScrollView()
        configTableView()
        // configDataSource()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        selectFirstItem()
    }
    
    func configScrollView() {
        scrollView = NSScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.width, .height]
        
        // This needs to be false (default), otherwise the top part of the toolbar will be a
        // different shade of white than the content. This only needs to be set to true in the
        // sidebar
        // scrollView.drawsBackground = false
        
        scrollView.hasVerticalScroller = true
        // scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        // scrollView.usesPredominantAxisScrolling = false
        view.addSubview(scrollView)
    }
    
    func configTableView() {
        tableView = NSTableView()
        tableView.autoresizingMask = [.width, .height]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil // No header
        tableView.usesAutomaticRowHeights = true
        tableView.gridStyleMask = .solidHorizontalGridLineMask
        // tableView.style = .inset
        // tableView.wantsLayer = true
        
        // print(tableView.contentHuggingPriority(for: .vertical))
        // print(tableView.allowsExpansionToolTips)
        // print(tableView.columnAutoresizingStyle.rawValue, NSTableView.ColumnAutoresizingStyle.lastColumnOnlyAutoresizingStyle.rawValue)
        // print(tableView.style.rawValue, NSTableView.Style.inset.rawValue)
        // print(tableView.allowsMultipleSelection)
        // print(tableView.autosaveTableColumns)
        // print(tableView.rowHeight)
        // print(tableView.usesAutomaticRowHeights)
        // print(tableView.wantsLayer)
        // print(tableView.effectiveStyle.rawValue, NSTableView.Style.inset.rawValue)
        
        // Create the table column
        let itemColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "NotesColumn"))
        // TODO: Change this
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
    
    // func configDataSource() {
    //     dataSource = NSTableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, tableColumn, row, identifier in
    //         guard let note: Note = self.dataController.getManagedObject(id: identifier) else {
    //             preconditionFailure("fuck")
    //         }
    //         
    //         let cellIdentifier = NSUserInterfaceItemIdentifier("NoteCell2")
    //         if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSHostingView<NoteCellView> {
    //             cell.rootView = NoteCellView(note: note).padding(10) as! NoteCellView
    //             return cell
    //         }
    //         
    //         let cellView = NoteCellView(note: note).padding(10)
    //         let hostingView = NSHostingView(rootView: cellView)
    //         hostingView.identifier = cellIdentifier
    //         
    //         return hostingView
    //     })
    // }
    
    func selectFirstItem() {
        if tableView.numberOfRows > 0 && tableView.selectedRow == -1 {
            // Select first column
            tableView.selectColumnIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            // Select first row in table
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            // Scroll to the top
            tableView.scrollRowToVisible(0)
        }
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let handler = handler else { return }
        guard let tableView = notification.object as? NSTableView else { return }
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 {
            let note = frc.fetchedObjects![selectedRow]
            handler(note)
        }
    }
    
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
    
    // func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, 
    //                 didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    //     dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>,
    //                      animatingDifferences: true)
    // }

}
