//
//  SidebarViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit
import CoreData
import SwiftUI

class SidebarViewController: UIViewController {

    var dataController = (UIApplication.shared.delegate as! AppDelegate).dataController

    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!
    var frc: NSFetchedResultsController<Folder>!
    var renameFolderAlert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        configVC()
        configCollectionView()
        configDataSource()
        configSupplementaryViews()
        configFRC()
    }

    var isCompact: Bool {
        if let splitViewController = splitViewController {
            return splitViewController.isCollapsed
        } else {
            return true
        }
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

    @objc func renameAlertTextDidChange(_ textField: UITextField) {
        guard let okButton = renameFolderAlert?.actions.first else { return }

        if let text = textField.text, text.isEmpty {
            // change to ?
            okButton.isEnabled = false
        } else {
            okButton.isEnabled = true
        }
    }

    func configCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            guard let sectionKind = SidebarSection(rawValue: sectionIndex) else { return nil }
            var configuration = UICollectionLayoutListConfiguration(appearance: self.isCompact ? .insetGrouped : .sidebar)

            switch sectionKind {
            case .groups:
                configuration.headerMode = .none
            case .folders:
                configuration.headerMode = .supplementary
                configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                    guard let self = self else { return nil }

                    let snapshot = self.dataSource.snapshot()
                    guard case .folder(let folderID) = snapshot.itemIdentifiers(inSection: .folders)[indexPath.row],
                          let folder: Folder = dataController.getManagedObject(id: folderID)
                    else { return nil }

                    // Delete button
                    let del = UIContextualAction(style: .destructive, title: "Delete") {
                        action, view, completion in
                        self.dataController.delete(folder)
                        self.dataController.save()
                        completion(true)
                    }
                    del.image = UIImage(systemName: "trash.fill")

                    // Rename button
                    // Displays an error: Changing the translatesAutoresizingMaskIntoConstraints
                    // property of a UICollectionViewCell that is managed by a UICollectionView is
                    // not supported, and will result in incorrect self-sizing.
                    // This error seems to be fine, however. No reason to panic
                    let rename = UIContextualAction(style: .normal, title: "Rename") {
                        action, view, completion in

                        // Alert is declared at the top of the view controller
                        let alert = UIAlertController(title: "Rename folder", message: nil, preferredStyle: .alert)
                        alert.addTextField { textField in
                            textField.placeholder = "Name"
                            textField.text = folder.safeName
                            // textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged
                            textField.addTarget(self, action: #selector(self.renameAlertTextDidChange), for: .editingChanged)
                        }
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak alert] action in
                            guard let newName = alert?.textFields?.first?.text else { return }

                            folder.safeName = newName
                            self.dataController.save()
                            completion(true)
                        })
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                            completion(true)
                        })
                        self.renameFolderAlert = alert

                        self.present(self.renameFolderAlert!, animated: true)
                    }
                    rename.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .black))
                    rename.backgroundColor = UIColor(.yellow)

                    return UISwipeActionsConfiguration(actions: [del, rename])
                }


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
        }

        let folderCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> { (cell, indexPath, item) in
            guard let folder: Folder = self.dataController.getManagedObject(id: item) else { return }

            var content = cell.defaultContentConfiguration()
            content.text = folder.safeName
            content.image = UIImage(systemName: folder.safeIcon)
            cell.contentConfiguration = content
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


extension SidebarViewController: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        var coreDataSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        var snapshot = dataSource.snapshot() // Start with current snapshot

        // Reload data if there are changes
        // let reloadIdentifiers: [NSManagedObjectID] = coreDataSnapshot.itemIdentifiers.compactMap { itemIdentifier in
        //     // Index of folder in current snapshot
        //     let currentIndex: Int?
        //     if snapshot.sectionIdentifiers.isEmpty {
        //         currentIndex = snapshot.indexOfItem(.folder(itemIdentifier))
        //     } else {
        //         currentIndex = snapshot.itemIdentifiers(inSection: .folders).firstIndex(of: .folder(itemIdentifier))
        //     }
        //
        //     // Index of folder in core data snapshot
        //     let index = coreDataSnapshot.indexOfItem(itemIdentifier)
        //
        //     guard let currentIndex = currentIndex, let index = index, index == currentIndex else {
        //         return nil
        //     }
        //     guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
        //
        //     return itemIdentifier
        // }
        // coreDataSnapshot.reloadItems(reloadIdentifiers)
        // print(coreDataSnapshot.reloadedItemIdentifiers)

        // If it's the first fetch, add groups as well
        if snapshot.sectionIdentifiers.isEmpty {
            let groups = [NoteGroup.allNotes, NoteGroup.trash]
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

extension SidebarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = SidebarSection(rawValue: indexPath.section) else { return }
        let snapshot = dataSource.snapshot()

        let vc: UIViewController
        switch section {
        case .groups:
            guard case .group(let noteGroup) = snapshot.itemIdentifiers(inSection: .groups)[indexPath.row] else { return }

            if noteGroup == .allNotes {
                vc = NotesViewController()
            } else {
                vc = TrashViewController()
            }

        case .folders:
            guard case .folder(let folderID) = snapshot.itemIdentifiers(inSection: .folders)[indexPath.row],
                  let folder: Folder = dataController.getManagedObject(id: folderID) else { return }
            vc = NotesViewController(folder: folder)
        }

        if isCompact {
            collectionView.deselectItem(at: indexPath, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            splitViewController?.setViewController(vc, for: .supplementary)
        }
    }
}

struct SidebarViewPreviews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            UINavigationController(rootViewController: SidebarViewController())
        }
    }
}
