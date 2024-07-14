//
//  SidebarViewController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 6/20/24.
//

// TODO: Add sidebar groups and headers

import Cocoa
import SwiftUI

class SidebarViewController: NSViewController {
    
    let dataController = (NSApplication.shared.delegate as! AppDelegate).controller
    let handler: ((Note) -> Void)?
    
    var groups = [NoteGroup.allNotes, NoteGroup.trash]
    
    var outlineView: NSOutlineView!
    var scrollView: NSScrollView!
    var frc: NSFetchedResultsController<Folder>!
    // var dataSource: NSTableViewDiffableDataSource<Int, NSManagedObjectID>!
    
    init(handler: ((Note) -> Void)? = nil) {
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 150, height: 300))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configFRC()
        configScrollView()
        configOutlineView()
        // configDataSource()
    }
    
    func configScrollView() {
        scrollView = NSScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        // scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        // scrollView.usesPredominantAxisScrolling = false
        view.addSubview(scrollView)
    }
    
    func configOutlineView() {
        outlineView = NSOutlineView(frame: view.bounds)
        outlineView.autoresizingMask = [.width, .height]
        outlineView.delegate = self
        outlineView.dataSource = self
        outlineView.headerView = nil
        // outlineView.rowSizeStyle = .default
        // outlineView.style = .sourceList
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "SidebarColumn"))
        column.width = 179
        column.minWidth = 16
        column.maxWidth = 1000
        outlineView.addTableColumn(column)
        
        // Add the outline view to the scroll view
        scrollView.documentView = outlineView
    }
    
    // func configDataSource() {
    //     dataSource = NSTableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, tableColumn, row, identifier in
    //         guard let folder: Folder = self.dataController.getManagedObject(id: identifier) else {
    //             preconditionFailure("fuck")
    //         }
    //         
    //         let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("FolderCell"), owner: self) as! NSTableCellView
    //         cell.imageView?.image = NSImage(systemSymbolName: folder.safeIcon, accessibilityDescription: "test")
    //         cell.textField?.stringValue = folder.safeName
    //         return cell
    //     
    //         // let cell = NSHostingView(rootView: Label(folder.safeName, systemImage: folder.safeIcon))
    //         // return cell
    //     })
    // }
    
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

extension SidebarViewController: NSOutlineViewDelegate {
    // func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    //     let identifier = NSUserInterfaceItemIdentifier("DataCell")
    // 
    //     var cell = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
    //     if cell == nil {
    //         cell = NSTableCellView()
    //         cell?.identifier = identifier
    //         let textField = NSTextField()
    //         cell?.textField = textField
    //         cell?.textField?.isEditable = false
    //         cell?.textField?.isBordered = false
    //         cell?.textField?.drawsBackground = false
    //         cell?.textField?.translatesAutoresizingMaskIntoConstraints = false
    //         cell?.addSubview(cell!.textField!)
    // 
    //         NSLayoutConstraint.activate([
    //             cell!.textField!.leadingAnchor.constraint(equalTo: cell!.leadingAnchor, constant: 5),
    //             cell!.textField!.trailingAnchor.constraint(equalTo: cell!.trailingAnchor, constant: -5),
    //             cell!.textField!.topAnchor.constraint(equalTo: cell!.topAnchor, constant: 2),
    //             cell!.textField!.bottomAnchor.constraint(equalTo: cell!.bottomAnchor)
    //         ])
    //     }
    // 
    //     cell?.textField?.stringValue = item as? String ?? ""
    // 
    //     return cell
    // }
    
    func outlineView(_ outlineView: NSOutlineView,
                     viewFor tableColumn: NSTableColumn?,
                     item: Any) -> NSView? {
        // guard let folder = frc.fetchedObjects?[item as? Int] else { return nil }
        // guard let index = item as? Int, let folders = frc.fetchedObjects else { return nil }
        // let folder = folders[index]
        guard let folder = item as? Folder else { return nil }
        let cellID = NSUserInterfaceItemIdentifier("FolderCell")
        if let cell = outlineView.makeView(withIdentifier: cellID, owner: self) as? NSTableCellView {
            cell.imageView?.image = NSImage(systemSymbolName: folder.safeIcon,
                                            accessibilityDescription: folder.safeIcon)
            cell.textField?.stringValue = folder.safeName
            return cell
        }
        
        // TODO: Finish implementing this
        let cell = NSTableCellView()
        cell.identifier = cellID
        let imageView = NSImageView(image: NSImage(systemSymbolName: folder.safeIcon,
                                                  accessibilityDescription: folder.safeIcon)!)
        let textField = NSTextField(string: folder.safeName)
        cell.imageView = imageView
        cell.textField = textField
        return cell
    }
}

extension SidebarViewController: NSOutlineViewDataSource {
    // func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    //     return 10
    // }
    // 
    // func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    //     return false
    // }
    // 
    // func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    //     return 
    // }
    // 
    // func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
    //     return item
    // }
    
    // https://stackoverflow.com/questions/45373039/how-to-program-a-nsoutlineview
    func outlineView(_ outlineView: NSOutlineView,
                     numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil, let numFolders = frc.fetchedObjects?.count {
            return numFolders
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil, let folders = frc.fetchedObjects {
            return folders[index]
        } else {
            return 0
        }
        // return index
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     isItemExpandable item: Any) -> Bool {
        return false
    }
}

extension SidebarViewController: NSFetchedResultsControllerDelegate {
    // Impementation based on this blog post:
    // https://samwize.com/2018/11/16/guide-to-nsfetchedresultscontroller-with-nstableview-macos/
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                outlineView.insertItems(at: [newIndexPath.item], inParent: nil, withAnimation: .slideDown)
            }
        case .delete:
            if let indexPath = indexPath {
                outlineView.removeItems(at: [indexPath.item], inParent: nil, withAnimation: .slideUp)
            }
        case .update:
            if let indexPath = indexPath {
                let row = indexPath.item
                for column in 0..<outlineView.numberOfColumns {
                    outlineView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: column))
                }
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                outlineView.removeItems(at: [indexPath.item], inParent: nil, withAnimation: .effectFade)
                outlineView.removeItems(at: [newIndexPath.item], inParent: nil, withAnimation: .effectFade)
            }
        default:
            fatalError("OutlineView operation not supported")
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        outlineView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        outlineView.endUpdates()
    }
    
    // func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    //     // var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
    //     // let currentSnapshot = dataSource.snapshot()
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
    //     // dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: collectionView.numberOfSections != 0)
    //     dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: true)
    // }
}

// class SidebarViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
//
//     var outlineView: NSOutlineView!
//     var scrollView: NSScrollView!
//
//     init() {
//         super.init(nibName: nil, bundle: nil)
//     }
//
//     required init?(coder: NSCoder) {
//         fatalError("init(coder:) has not been implemented")
//     }
//
//     override func loadView() {
//         super.loadView()
//         self.view = NSView(frame: NSRect(x: 0, y: 0, width: 150, height: 300))
//         setupOutlineView()
//     }
//
//     private func setupOutlineView() {
//         // Create and configure the scroll view
//         scrollView = NSScrollView(frame: view.bounds)
//         scrollView.autoresizingMask = [.width, .height]
//         self.view.addSubview(scrollView)
//
//         // Create and configure the outline view
//         outlineView = NSOutlineView(frame: view.bounds)
//         outlineView.autoresizingMask = [.width, .height]
//         outlineView.rowSizeStyle = .default
//         outlineView.style = .sourceList
//         outlineView.delegate = self
//         outlineView.dataSource = self
//
//         // Add a column to the outline view
//         let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Column"))
//         outlineView.addTableColumn(column)
//         outlineView.headerView = nil // Remove the header
//         
//         // Embed the outline view in the scroll view
//         scrollView.documentView = outlineView
//     }
//     
//     // MARK: - NSOutlineViewDataSource
//     
//     func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
//         return 10 // Example: 3 items at the top level
//     }
//     
//     func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
//         return true // All items are expandable
//     }
//     
//     func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
//         return "Item \(index)" // Example: return a string for each item
//     }
//     
//     func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
//         return item
//     }
//     
//     // MARK: - NSOutlineViewDelegate
//     
//     func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
//         let identifier = NSUserInterfaceItemIdentifier("DataCell")
//         
//         var cell = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
//         if cell == nil {
//             cell = NSTableCellView()
//             cell?.identifier = identifier
//             let textField = NSTextField()
//             cell?.textField = textField
//             cell?.textField?.isEditable = false
//             cell?.textField?.isBordered = false
//             cell?.textField?.drawsBackground = false
//             cell?.textField?.translatesAutoresizingMaskIntoConstraints = false
//             cell?.addSubview(cell!.textField!)
//             
//             NSLayoutConstraint.activate([
//                 cell!.textField!.leadingAnchor.constraint(equalTo: cell!.leadingAnchor, constant: 5),
//                 cell!.textField!.trailingAnchor.constraint(equalTo: cell!.trailingAnchor, constant: -5),
//                 cell!.textField!.topAnchor.constraint(equalTo: cell!.topAnchor, constant: 2),
//                 cell!.textField!.bottomAnchor.constraint(equalTo: cell!.bottomAnchor)
//             ])
//         }
//         
//         cell?.textField?.stringValue = item as? String ?? ""
//         
//         return cell
//     }
// }
