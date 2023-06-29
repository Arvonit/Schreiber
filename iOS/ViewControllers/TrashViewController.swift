//
//  TrashViewController.swift
//  Schreiber (iOS)
//
//  Created by Arvind on 6/27/23.
//

import UIKit
import CoreData
import SwiftUI

class TrashViewController: UIViewController {
    
    var dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy h:mm a"
        return formatter
    }()
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!
    var frc: NSFetchedResultsController<Note>!
    
    var isCompact: Bool {
        if let splitViewController = splitViewController {
            return splitViewController.isCollapsed
        } else {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configVC()
        configCollectionView()
        configDataSource()
        configFRC()
    }
            
    func configVC() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Trash"
    }
    
    func configCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: isCompact ? .insetGrouped : .sidebarPlain)
        
        // Delete swipe action
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            guard let note: Note = dataController.getManagedObject(
                id: self.dataSource.snapshot().itemIdentifiers[indexPath.row]) else { return nil }
            
            let del = UIContextualAction(style: .destructive, title: "Delete") {
                action, view, completion in
                self.dataController.delete(note)
                self.dataController.save()

                completion(true)
            }
            del.image = UIImage(systemName: "trash.fill")
            
            return UISwipeActionsConfiguration(actions: [del])
        }
        
        // Restore swipe action
        configuration.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            guard let note: Note = dataController.getManagedObject(
                id: self.dataSource.snapshot().itemIdentifiers[indexPath.row]) else { return nil }
            
            let restore = UIContextualAction(style: .destructive, title: "Restore") {
                action, view, completion in
                note.inTrash = false
                self.dataController.save()

                completion(true)
            }
            restore.image = UIImage(systemName: "trash.slash.fill")
            restore.backgroundColor = UIColor(Color.purple)

            return UISwipeActionsConfiguration(actions: [restore])
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
    
    func configDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> { (cell, indexPath, item) in
            guard let note: Note = self.dataController.getManagedObject(id: item) else {
                return
            }
                        
            var content = cell.defaultContentConfiguration()
            content.text = note.title
            content.secondaryText = self.dateFormatter.string(from: note.safeDate)
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: NSManagedObjectID) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    func configFRC() {
        let request = Note.fetchRequest()
        request.predicate = NSPredicate(format: "inTrash == true")
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
    }
    
}

extension TrashViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        let currentSnapshot = dataSource.snapshot()

        // Reload data if there are changes
        // let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
        //     guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
        //         return nil
        //     }
        //     guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
        //     return itemIdentifier
        // }
        // snapshot.reloadItems(reloadIdentifiers)

        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: collectionView.numberOfSections != 0)
    }
}

extension TrashViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        guard let note: Note = dataController.getManagedObject(id: snapshot.itemIdentifiers[indexPath.row]) else {
            return
        }
        let vc = NoteEditorController(note: note)
        
        // Cannot edit notes in trash
        // vc.editor.isEditable = false
        
        if isCompact {
            collectionView.deselectItem(at: indexPath, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            splitViewController?.setViewController(nil, for: .secondary)
            splitViewController?.setViewController(vc, for: .secondary)
        }
    }
}

struct TrashViewPreviews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            UINavigationController(rootViewController: TrashViewController())
        }
    }
}
