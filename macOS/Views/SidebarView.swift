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
    // @State var selectedFolder: UUID? = nil
    @State var selectedItem: ListItem? = nil
    var labels = [
        MenuItem(name: "All Notes", image: "tray.full"),
        MenuItem(name: "Trash", image: "trash")
    ]

    var body: some View {
        List(selection: $selectedItem) {
            ForEach(labels) { label in
                Label(label.name, systemImage: label.image)
                    .tag(ListItem.item(label))
            }
            
            Section(header: Text("Folders")) {
                ForEach(folders) { folder in
                    Label(folder.safeName, systemImage: folder.safeIcon)
                        .tag(ListItem.folder(folder))
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

struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let image: String
}

enum ListItem: Hashable {
    case folder(Folder)
    case item(MenuItem)
}
