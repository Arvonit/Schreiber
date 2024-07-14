//
//  SidebarView.swift
//  Schreiber
//
//  Created by Arvind on 6/22/23.
//

import SwiftUI

struct SidebarView: View {
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor<Folder>(\.name)],
                  animation: .default) private var folders
    @State var selectedItem: SidebarItem? = nil
    var groups = [NoteGroup.allNotes, NoteGroup.trash]
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
                        .swipeActions(edge: .trailing) {
                            deleteSwipeAction(folder: folder)
                        }
                }
            }
        }
        .listStyle(.sidebar)
        .onChange(of: selectedItem) { oldValue, newValue in
            if let handler = handler, let newValue = newValue {
                handler(newValue)
            }
        }
        .onAppear {
            selectedItem = .group(NoteGroup.allNotes)
        }
    }
    
    private func deleteSwipeAction(folder: Folder) -> some View {
        Button(role: .destructive) {
            context.delete(folder)
            try! context.save()
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
        .tint(.red)
    }
}

#Preview {
    SidebarView()
        .environment(\.managedObjectContext, DataController.preview.context)
}

