//
//  SidebarView.swift
//  Schreiber
//
//  Created by Arvind on 6/22/23.
//

import SwiftUI

struct SidebarView: View {
    // @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor<Folder>(\.name)]) private var folders
    @State var selectedFolder: UUID? = nil
    var labels = [MenuItem(name: "All Notes", image: "tray.full")]

    var body: some View {
        List(selection: $selectedFolder) {
            ForEach(labels, id: \.id) { label in
                Label(label.name, systemImage: label.image)
            }
            
            Section(header: Text("Folders")) {
                ForEach(folders, id: \.safeID) { folder in
                    Label(folder.safeName, systemImage: folder.safeIcon)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Hello")
    }
}

struct SidebarViewPreviews: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .environment(\.managedObjectContext, DataController.preview.context)
    }
}
