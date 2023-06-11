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
    var dataSource: UICollectionViewDiffableDataSource<Int, Folder>!
    var controller: NSFetchedResultsController<Folder>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configVC()
        configCollectionView()
        configDataSource()
        configFRC()
        fetchSnapshot()
    }
    
    func configVC() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }

            let folder = self.dataSource.snapshot().itemIdentifiers[indexPath.row]
            
            let del = UIContextualAction(style: .destructive, title: "Delete") {
                action, view, completion in
                self.dataController.delete(folder)
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [del])
        }
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
//        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    func configDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Folder> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.safeName
            content.image = UIImage(systemName: item.safeIcon)
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Folder>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Folder) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    func configFRC() {
        let request = Folder.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        try! controller.performFetch()
    }
    
    func fetchSnapshot() {
        var ddsSnapshot = NSDiffableDataSourceSnapshot<Int, Folder>()
        ddsSnapshot.appendSections([0])
        ddsSnapshot.appendItems(controller.fetchedObjects ?? [])
        dataSource?.apply(ddsSnapshot, animatingDifferences: true)
    }
    
}

extension FoldersViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        fetchSnapshot()
    }
}

extension FoldersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        let folder = snapshot.itemIdentifiers[indexPath.row]
        let vc = NotesViewController(folder: folder)
        print(folder.safeName)
        navigationController?.pushViewController(vc, animated: true)
    }
}

