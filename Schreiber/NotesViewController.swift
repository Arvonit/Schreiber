//
//  NotesViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    let folder: Folder?
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy h:mm a"
        return formatter
    }()
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, Note>!
    var frc: NSFetchedResultsController<Note>!
    
    init(folder: Folder? = nil) {
        self.folder = folder
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
        fetchSnapshot()
    }
    
    func configVC() {
        navigationController?.navigationBar.prefersLargeTitles = true
        if let folder = folder {
            title = folder.safeName
        }
    }
    
    func configCollectionView() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    func configDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Note> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.secondaryText = self.dateFormatter.string(from: item.safeDate)
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Note>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Note) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    func configFRC() {
        let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
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
    
    func fetchSnapshot() {
        var ddsSnapshot = NSDiffableDataSourceSnapshot<Int, Note>()
        ddsSnapshot.appendSections([0])
        ddsSnapshot.appendItems(frc.fetchedObjects ?? [])
        dataSource?.apply(ddsSnapshot, animatingDifferences: true)
    }
    
}

extension NotesViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        fetchSnapshot()
    }
}

extension NotesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        let note = snapshot.itemIdentifiers[indexPath.row]
        let vc = NoteEditorViewController(note: note)
        print(note.id)
        navigationController?.pushViewController(vc, animated: true)
    }
}
