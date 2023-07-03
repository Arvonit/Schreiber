//
//  NotesViewController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 6/15/23.
//

import Cocoa
import SwiftUI

class NotesViewController: NSViewController {
    
    let dataController = (NSApplication.shared.delegate as! AppDelegate).controller
    
    @IBOutlet weak var tableView: NSTableView!
    // var dataSource: NSTableViewDiffableDataSource<Int, NSManagedObjectID>!
    var frc: NSFetchedResultsController<Note>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configFRC()
        configTableView()
        // configDataSource()
    }
    
    func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: 275)
        ])
    }
    
    // func configDataSource() {
    //     dataSource = NSTableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, tableColumn, row, identifier in
    //         guard let note: Note = self.dataController.getManagedObject(id: identifier) else {
    //             preconditionFailure("fuck")
    //         }
    //
    //         let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("NoteCell"), owner: self) as! NSTableCellView
    //         cell.textField?.stringValue = note.title
    //         return cell
    //     })
    // }
    
    func configFRC() {
        let request = Note.fetchRequest()
        request.predicate = NSPredicate(format: "inTrash == false")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
    }
        
}

extension NotesViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("NoteCell"), owner: self) as! NSTableCellView
        configureCell(cell: cell, row: row)
        return cell
    }

    private func configureCell(cell: NSTableCellView, row: Int) {
        let note = frc.fetchedObjects![row]
        cell.textField?.stringValue = note.title
    }

    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
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
    
    // https://samwize.com/2018/11/16/guide-to-nsfetchedresultscontroller-with-nstableview-macos/
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath.item], withAnimation: .effectFade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.removeRows(at: [indexPath.item], withAnimation: .slideUp)
            }
        case .update:
            if let indexPath = indexPath {
                let row = indexPath.item
                for column in 0..<tableView.numberOfColumns {
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

    // func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    //     var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
    //     let currentSnapshot = dataSource.snapshot()
    //
    //     // Reload data if there are changes
    //     // let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
    //     //     guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
    //     //         return nil
    //     //     }
    //     //     guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
    //     //     return itemIdentifier
    //     // }
    //     // snapshot.reloadItems(reloadIdentifiers)
    //
    //     dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: true)
    // }
    
}
