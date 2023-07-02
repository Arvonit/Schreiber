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
    @State var selectedItem: ListItem? = nil
    var groups = [
        NoteGroup.allNotes,
        NoteGroup.trash
    ]

    var body: some View {
        List(selection: $selectedItem) {
            ForEach(groups) { group in
                Label(group.name, systemImage: group.icon)
                    .tag(ListItem.item(group))
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

enum ListItem: Hashable {
    case folder(Folder)
    case item(NoteGroup)
}
