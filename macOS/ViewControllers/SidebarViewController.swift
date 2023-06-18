//
//  SidebarViewController.swift
//  Schreiber (iOS)
//
//  Created by Arvind on 6/14/23.
//

import Cocoa
import SwiftUI

class SidebarViewController: NSViewController {
    
    let dataController = (NSApplication.shared.delegate as! AppDelegate).controller
    
    @IBOutlet weak var tableView: NSTableView!
    var dataSource: NSTableViewDiffableDataSource<Int, NSManagedObjectID>!
    var frc: NSFetchedResultsController<Folder>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        configDataSource()
        configFRC()
    }
    
    func configTableView() {
        // tableView.style = .inset
    }
    
    func configDataSource() {
        dataSource = NSTableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, tableColumn, row, identifier in
            guard let folder: Folder = self.dataController.getManagedObject(id: identifier) else {
                preconditionFailure("fuck")
            }
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("FolderCell"), owner: self) as! NSTableCellView
            cell.imageView?.image = NSImage(systemSymbolName: folder.safeIcon, accessibilityDescription: "test")
            cell.textField?.stringValue = folder.safeName
            return cell
        
            // let cell = NSHostingView(rootView: Label(folder.safeName, systemImage: folder.safeIcon))
            // return cell
        })
    }
    
    func configFRC() {
        let request = Folder.fetchRequest()
        request.predicate = NSPredicate(value: true)
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
    }
    
}

extension SidebarViewController: NSFetchedResultsControllerDelegate {
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

        // dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: collectionView.numberOfSections != 0)
        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: true)
    }
}
