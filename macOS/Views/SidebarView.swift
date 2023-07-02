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
    @State var selectedItem: SidebarItem? = nil
    var groups = [
        NoteGroup.allNotes,
        NoteGroup.trash
    ]
    var handler: ((SidebarItem) -> Void)? = nil
    
    var body: some View {
        List(selection: $selectedItem) {
            ForEach(groups) { group in
                Label(group.name, systemImage: group.icon)
                    .tag(SidebarItem.group(group))
            }
            
            Section(header: Text("Folders")) {
                ForEach(folders) { folder in
                    FolderCellView(folder: folder)
                        .tag(SidebarItem.folder(folder.objectID))
                }
            }
        }
        .listStyle(.sidebar)
        .onChange(of: selectedItem) { newValue in
            if let handler = handler {
                handler(newValue!)
            }
        }
    }
}

struct SidebarViewPreviews: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .environment(\.managedObjectContext, DataController.preview.context)
    }
}
