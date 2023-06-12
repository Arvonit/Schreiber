//
//  TestViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit
import CoreData

class TestViewController: UIViewController {
    
    let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!
    var frc: NSFetchedResultsController<Folder>!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configVC()
        configCollectionView()
        configDataSource()
        configFRC()
    }
    
    func foo<T>(with moID: NSManagedObjectID) -> T? {
        do {
            let object = try dataController.context.existingObject(with: moID)
            return object as? T
        } catch let err {
            fatalError(err.localizedDescription)
        }
    }
    
    func configVC() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewNote)
        )
    }
    
    @objc func addNewNote() {
        let _ = Folder(name: "Test", context: dataController.context)
        dataController.save()
    }
    
    func configCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }

            guard let folder: Folder = foo(with: self.dataSource.snapshot().itemIdentifiers[indexPath.row]) else { return nil }
            
            let del = UIContextualAction(style: .destructive, title: "Delete") {
                action, view, completion in
                self.dataController.delete(folder)
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [del])
        }
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    func configDataSource() {
//        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Note> { (cell, indexPath, item) in
//            var content = cell.defaultContentConfiguration()
//            content.text = item.title
//            content.secondaryText = self.dateFormatter.string(from: item.safeDate)
//            cell.contentConfiguration = content
//        }
//
//        dataSource = UICollectionViewDiffableDataSource<Int, Note>(collectionView: collectionView) {
//            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Note) -> UICollectionViewCell? in
//
//            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
//        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            guard let folder: Folder = self.foo(with: item) else {
                preconditionFailure("fuck")
            }
            content.text = folder.safeName
            content.secondaryText = folder.safeIcon
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: NSManagedObjectID) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    func configFRC() {
        let request = Folder.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: false)
        ]
        
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
    }
    
}

extension TestViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        let currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>

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

extension TestViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let snapshot = dataSource.snapshot()
//        guard let note: Note = foo(with: snapshot.itemIdentifiers[indexPath.row]) else {
//            return
//        }
//        let vc = NoteEditorController(note: note)
//        navigationController?.pushViewController(vc, animated: true)
    }
}
