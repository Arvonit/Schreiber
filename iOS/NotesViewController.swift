//
//  NotesViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    @IBOutlet weak var tableView: NSTableView!
    let folder: Folder?
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy h:mm a"
        return formatter
    }()
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!
    var frc: NSFetchedResultsController<Note>!
    
    init(folder: Folder? = nil) {
        self.folder = folder
        // self.dataController = dataController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        if let folder = folder {
            title = folder.safeName
        } else {
            title = "All Notes"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewNote)
        )
    }
    
    @objc func addNewNote() {
        let newNote = Note(folder: folder, context: dataController.context)
        dataController.save()
        
        var indexPath: IndexPath? = nil
        
        if let index = dataSource.snapshot().indexOfItem(newNote.objectID) {
            indexPath = IndexPath(row: index, section: 0)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        }
        
        let vc = NoteEditorController(note: newNote)
        
        if splitViewController!.isCollapsed {
            if let indexPath = indexPath {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            splitViewController?.setViewController(nil, for: .secondary)
            splitViewController?.setViewController(vc, for: .secondary)
        }
    }
    
    func configCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }

            guard let note: Note = dataController.getManagedObject(id: self.dataSource.snapshot().itemIdentifiers[indexPath.row]) else { return nil }
            
            let del = UIContextualAction(style: .destructive, title: "Delete") {
                action, view, completion in
                self.dataController.delete(note)
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [del])
        }
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    func configDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            guard let note: Note = self.dataController.getManagedObject(id: item) else {
                preconditionFailure("fuck")
            }
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
        if let folder = folder {
            request.predicate = NSPredicate(format: "folder == %@", folder)
        }
        request.sortDescriptors = [
            NSSortDescriptor(key: "content", ascending: false)
        ]
        
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
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

        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: collectionView.numberOfSections != 0)
    }
}

extension NotesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        guard let note: Note = dataController.getManagedObject(id: snapshot.itemIdentifiers[indexPath.row]) else {
            return
        }
        let vc = NoteEditorController(note: note)
        
        if splitViewController!.isCollapsed {
            collectionView.deselectItem(at: indexPath, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            splitViewController?.setViewController(nil, for: .secondary)
            splitViewController?.setViewController(vc, for: .secondary)
        }
    }
}

