//
//  ViewHelper.swift
//  Schreiber (iOS)
//
//  Created by Arvind on 7/1/23.
//

import UIKit
import CoreData
import SwiftUI

enum ViewHelper {
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy h:mm a"
        return formatter
    }()

    static func makeFoldersHeader() -> UICollectionView.SupplementaryRegistration<
        UICollectionViewListCell
    > {
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { (supplementaryView, elementKind, indexPath) in
            // Make sure section is Folders
            guard let sectionKind = SidebarSection(rawValue: indexPath.section),
                  case .folders = sectionKind else { return }

            var content = UIListContentConfiguration.sidebarHeader()
            content.text = "Folders"
            supplementaryView.contentConfiguration = content
        }
    }

    static func makeNoteCell(using dataController: DataController) ->
        UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> {

        return UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> {
            (cell, indexPath, item) in
            guard let note: Note = dataController.getManagedObject(id: item) else {
                return
            }

            var content = cell.defaultContentConfiguration()
            content.text = note.title
            content.secondaryText = dateFormatter.string(from: note.safeDate)
            cell.contentConfiguration = content
        }
    }

}
