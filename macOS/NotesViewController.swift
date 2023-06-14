//
//  NotesViewController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 6/15/23.
//

import Cocoa

class NotesViewController: NSViewController {
    
    let dataController = (NSApplication.shared.delegate as! AppDelegate).controller
    
    @IBOutlet var tableView: NSTableView!
    var dataSource: NSTableViewDiffableDataSource<Int, NSManagedObjectID>!
    var frc: NSFetchedResultsController<Note>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        configDataSource()
        configFRC()
    }
    
    func configTableView() {
        // tableView.style = .inset
        tableView.delegate = self
    }
    
    func configDataSource() {
        dataSource = NSTableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, tableColumn, row, identifier in
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("NoteCell"), owner: self) as! NSTableCellView
            guard let note: Note = self.dataController.getManagedObject(id: identifier) else {
                return cell
            }
            cell.textField?.stringValue = note.title
            return cell
        })
    }
    
    func configFRC() {
        let request = Note.fetchRequest()
        request.predicate = NSPredicate(value: true)
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
    }
    
}

extension NotesViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        
    }
}

extension NotesViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        let currentSnapshot = dataSource.snapshot()

        // Reload data if there are changes
        let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
            guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
                return nil
            }
            guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
            return itemIdentifier
        }
        snapshot.reloadItems(reloadIdentifiers)

        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: true)
    }
}
