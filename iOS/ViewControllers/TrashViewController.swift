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
    
    func makeListLayout() -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(
            appearance: isCompact ? .insetGrouped : .sidebarPlain
        )
        
        // Delete swipe action
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            guard let note: Note = dataController.getManagedObject(
                id: self.dataSource.snapshot().itemIdentifiers[indexPath.row]) else { return nil }
                        
            let del = self.makeDeleteSwipeAction(for: note)
            
            return UISwipeActionsConfiguration(actions: [del])
        }
        
        // Restore swipe action
        configuration.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            guard let note: Note = dataController.getManagedObject(
                id: self.dataSource.snapshot().itemIdentifiers[indexPath.row]) else { return nil }
            
            let restore = self.makeRestoreSwipeAction(for: note)
            
            return UISwipeActionsConfiguration(actions: [restore])
        }
        
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    func makeDeleteSwipeAction(for note: Note) -> UIContextualAction {
        let del = UIContextualAction(style: .destructive, title: "Delete") {
            action, view, completion in
            self.dataController.delete(note)
            self.dataController.save()

            completion(true)
        }
        del.image = UIImage(systemName: "trash.fill")
        
        return del
    }
    
    func makeRestoreSwipeAction(for note: Note) -> UIContextualAction {
        let restore = UIContextualAction(style: .destructive, title: "Restore") {
            action, view, completion in
            note.inTrash = false
            self.dataController.save()

            completion(true)
        }
        restore.image = UIImage(systemName: "trash.slash.fill")
        restore.backgroundColor = UIColor(Color.purple)

        return restore
    }
    
    func configCollectionView() {
        let layout = makeListLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
    
    func configDataSource() {
        let cellRegistration = ViewHelper.makeNoteCell(using: dataController)
        
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: item)
        }
    }
    
    func configFRC() {
        let request = Note.fetchRequest()
        request.predicate = NSPredicate(format: "inTrash == true")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        frc = NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: dataController.context,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
    }
    
}

extension TrashViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>

        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>,
                         animatingDifferences: collectionView.numberOfSections != 0)
    }
}

extension TrashViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = dataSource.snapshot().itemIdentifiers[indexPath.row]
        guard let note: Note = dataController.getManagedObject(id: id) else {
            return
        }
        let vc = NoteEditorController(note: note)
        
        if isCompact {
            collectionView.deselectItem(at: indexPath, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            splitViewController?.setViewController(nil, for: .secondary)
            splitViewController?.setViewController(vc, for: .secondary)
        }
    }
}

#Preview {
    UINavigationController(rootViewController: TrashViewController())
}
