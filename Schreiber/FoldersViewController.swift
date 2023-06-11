//
//  FoldersViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit
import CoreData

class FoldersViewController: UIViewController {
    
    enum Section {
        case main
    }
    
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
    }
    
    func configCollectionView() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        view.addSubview(collectionView)
    }
    
    func configDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Folder> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.name
            content.image = UIImage(systemName: item.safeIcon)
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Folder>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Folder) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    func configFRC() {
        let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
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

#Preview {
    TripleColumnViewController()
}
