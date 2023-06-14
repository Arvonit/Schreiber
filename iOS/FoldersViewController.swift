//
//  FoldersViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit
import CoreData

class FoldersViewController: UIViewController {
    
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
    
    func configVC() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Schreiber"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewFolder)
        )
    }
    
    @objc func addNewFolder() {
        let alert = UIAlertController(title: "Add new folder", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak alert] _ in
            guard let name = alert?.textFields?.first?.text else { return }
            let _ = Folder(name: name, context: self.dataController.context)
            self.dataController.save()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        
        present(alert, animated: true)
    }
    
    func configCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            
            print(dataSource.snapshot().itemIdentifiers[indexPath.row].isTemporaryID)
            guard let folder: Folder = dataController.getManagedObject(id: self.dataSource.snapshot().itemIdentifiers[indexPath.row]) else {
                return nil
            }
            
            let del = UIContextualAction(style: .destructive, title: "Delete") {
                action, view, completion in
                self.dataController.delete(folder)
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
            guard let folder: Folder = self.dataController.getManagedObject(id: item) else {
                return
            }
            content.text = folder.safeName
            content.image = UIImage(systemName: folder.safeIcon)
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: NSManagedObjectID) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
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

extension FoldersViewController: NSFetchedResultsControllerDelegate {
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

extension FoldersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        guard let folder: Folder = dataController.getManagedObject(id: snapshot.itemIdentifiers[indexPath.row]) else {
            return
        }
        let vc = NotesViewController(folder: folder)
        
        if splitViewController!.isCollapsed {
            collectionView.deselectItem(at: indexPath, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            splitViewController?.setViewController(vc, for: .supplementary)
        }
    }
}
