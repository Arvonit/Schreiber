//
//  NotesViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit
import CoreData
import SwiftUI

class NotesViewController: UIViewController {
    
    var dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    let folder: Folder?
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!
    var frc: NSFetchedResultsController<Note>!
    
    init(folder: Folder? = nil) {
        self.folder = folder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        if isCompact {
            if let indexPath = indexPath {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            splitViewController?.setViewController(nil, for: .secondary)
            splitViewController?.setViewController(vc, for: .secondary)
        }
    }
    
    func makeListLayout() -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(
            appearance: isCompact ? .insetGrouped : .sidebarPlain
        )
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            guard let note: Note = dataController.getManagedObject(
                id: self.dataSource.snapshot().itemIdentifiers[indexPath.row]) else { return nil }
            
            let del = self.makeDeleteSwipeAction(for: note)
            let move = self.makeMoveSwipeAction(for: note)
            
            return UISwipeActionsConfiguration(actions: [del, move])
        }
        
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    func makeDeleteSwipeAction(for note: Note) -> UIContextualAction {
        let del = UIContextualAction(style: .destructive, title: "Delete") {
            action, view, completion in
            // Move note to trash
            note.inTrash = true
            self.dataController.save()
            
            completion(true)
        }
        del.image = UIImage(systemName: "trash.fill")
        
        return del
    }
    
    func makeMoveSwipeAction(for note: Note) -> UIContextualAction {
        let move = UIContextualAction(style: .normal, title: "Move") {
            action, view, completion in
            // Display move note view as sheet
            let vc = MoveNoteViewController(note: note, currentFolder: note.folder)
            self.present(UINavigationController(rootViewController: vc), animated: true)
        }
        move.image = UIImage(systemName: "folder.fill")
        move.backgroundColor = UIColor(.yellow)

        return move
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
        ) {
            (collectionView, indexPath, item) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: item)
        }
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

extension NotesViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>

        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>,
                         animatingDifferences: collectionView.numberOfSections != 0)
    }
}

extension NotesViewController: UICollectionViewDelegate {
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
    UINavigationController(rootViewController: NotesViewController())
}

