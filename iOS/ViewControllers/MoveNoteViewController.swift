//
//  MoveNoteViewController.swift
//  Schreiber (iOS)
//
//  Created by Arvind on 6/28/23.
//

import UIKit
import CoreData
import SwiftUI

class MoveNoteViewController: UIViewController {

    let note: Note
    let currentFolder: Folder?
    var dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!
    var frc: NSFetchedResultsController<Folder>!
    
    init(note: Note, currentFolder: Folder? = nil) {
        self.note = note
        self.currentFolder = currentFolder
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
        configSupplementaryViews()
        configFRC()
    }
    
    func configVC() {
        // navigationController?.navigationBar.prefersLargeTitles = true
        title = "Move"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissVC)
        )
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }

    func configCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            guard let sectionKind = SidebarSection(rawValue: sectionIndex) else { return nil }
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)

            switch sectionKind {
            case .groups:
                configuration.headerMode = .none
            case .folders:
                configuration.headerMode = .supplementary
            }

            return NSCollectionLayoutSection.list(
                using: configuration,
                layoutEnvironment: layoutEnvironment
            )
        }

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    func configDataSource() {
        let groupCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NoteGroup> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.name
            content.image = UIImage(systemName: item.icon)
            cell.contentConfiguration = content
            
            if self.currentFolder == nil {
                cell.isUserInteractionEnabled = false
            }
        }

        let folderCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> { (cell, indexPath, item) in
            guard let folder: Folder = self.dataController.getManagedObject(id: item) else { return }

            var content = cell.defaultContentConfiguration()
            content.text = folder.safeName
            content.image = UIImage(systemName: folder.safeIcon)
            cell.contentConfiguration = content
            
            if folder == self.currentFolder {
                cell.isUserInteractionEnabled = false
            }
        }

        dataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: SidebarItem) -> UICollectionViewCell? in
            switch item {
            case .group(let noteGroup):
                return collectionView.dequeueConfiguredReusableCell(using: groupCellRegistration, for: indexPath, item: noteGroup)
            case .folder(let folderID):
                return collectionView.dequeueConfiguredReusableCell(using: folderCellRegistration, for: indexPath, item: folderID)
            }
        }
    }

    func configSupplementaryViews() {
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { supplementaryView, elementKind, indexPath in
            // Make sure section is Folders
            guard let sectionKind = SidebarSection(rawValue: indexPath.section),
                  case .folders = sectionKind else { return }

            var content = UIListContentConfiguration.sidebarHeader()
            content.text = "Folders"
            supplementaryView.contentConfiguration = content
        }

        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerCellRegistration,
                    for: indexPath
                )
            }
            return nil
        }
    }

    func configFRC() {
        let request = Folder.fetchRequest()
        request.predicate = NSPredicate(value: true)
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: dataController.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        try! frc.performFetch()
    }
}


extension MoveNoteViewController: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        let coreDataSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        var snapshot = dataSource.snapshot() // Start with current snapshot

        // If it's the first fetch, add groups as well
        if snapshot.sectionIdentifiers.isEmpty {
            let groups = [NoteGroup.allNotes]
            snapshot.appendSections(SidebarSection.allCases)
            snapshot.appendItems(groups.map { SidebarItem.group($0) }, toSection: .groups)
        }

        // Delete all folders and add them again from the Core Data snapshot
        snapshot.deleteSections([.folders])
        snapshot.appendSections([.folders])
        snapshot.appendItems(coreDataSnapshot.itemIdentifiers.map { .folder($0) }, toSection: .folders)
        snapshot.reconfigureItems(coreDataSnapshot.reloadedItemIdentifiers.map { .folder($0) }) // for some reason, we have to do it in this snapshot

        // Apply changes
        dataSource.apply(snapshot, animatingDifferences: collectionView.numberOfSections != 0)
    }

}

extension MoveNoteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // if !collectionView.cellForItem(at: indexPath)?.isUserInteractionEnabled { return }
        
        guard let section = SidebarSection(rawValue: indexPath.section) else { return }
        let snapshot = dataSource.snapshot()

        switch section {
        case .groups:
            guard case .group(let noteGroup) = snapshot.itemIdentifiers(inSection: .groups)[indexPath.row] else { return }
            if noteGroup == .allNotes {
                note.folder = nil
                dataController.save()
            }
        case .folders:
            guard case .folder(let folderID) = snapshot.itemIdentifiers(inSection: .folders)[indexPath.row],
                  let folder: Folder = dataController.getManagedObject(id: folderID) else { return }
            note.folder = folder
            dataController.save()
        }
        
        dismiss(animated: true)
    }
}

struct MoveNoteViewPreviews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            UINavigationController(rootViewController: SidebarViewController())
        }
    }
}
