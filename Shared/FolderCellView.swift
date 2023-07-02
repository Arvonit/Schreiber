//
//  FolderCellView.swift
//  Schreiber (iOS)
//
//  Created by Arvind on 7/2/23.
//

import SwiftUI

struct FolderCellView: View {
    let folder: Folder
    
    var body: some View {
        Label(folder.safeName, systemImage: folder.safeIcon)
    }
}

struct FolderCellViewPreviews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                FolderCellView(folder: Folder(name: "All Notes", icon: "tray.full", context: DataController.preview.context))
                FolderCellView(folder: Folder(name: "Trash", icon: "trash", context: DataController.preview.context))
                Section("Folders") {
                    FolderCellView(folder: Folder(name: "Blog", context: DataController.preview.context))
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Schreiber")
        }
    }
}
