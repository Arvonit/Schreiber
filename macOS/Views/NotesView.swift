//
//  NotesView.swift
//  Schreiber
//
//  Created by Arvind on 6/22/23.
//

import SwiftUI
import CoreData

struct NotesView: View {
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    // @State var selectedNotes = Set<UUID>()
    let folder: Folder?
    let handler: ((Note) -> Void)?
    @FetchRequest private var notes: FetchedResults<Note>
    @State var selectedNote: Note?
    
    init(folder: Folder? = nil, handler: ((Note) -> Void)? = nil) {
        self.folder = folder
        self.handler = handler
        
        let request = Note.fetchRequest()
        if let folder = folder {
            request.predicate = NSPredicate(format: "inTrash == false and folder == %@", folder)
        } else {
            request.predicate = NSPredicate(format: "inTrash == false")
        }
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        self._notes = FetchRequest(fetchRequest: request)
        self.selectedNote = nil
    }

    var body: some View {
        List(selection: $selectedNote) {
            ForEach(notes, id: \.self) { note in
                NoteCellView(note: note)
                    .swipeActions(edge: .trailing) {
                        deleteSwipeAction(note: note)
                    }
            }
        }
        // Delegate function
        .onChange(of: selectedNote) { newValue in
            if let handler = handler, let newValue = newValue {
                handler(newValue)
            }
        }
        // Select new note when it is added
        .onChange(of: notes.count) { newValue in
            selectedNote = notes.first
        }
        .onAppear {
            selectedNote = notes.first
        }
        .frame(minWidth: 275)
    }
    
    private func deleteSwipeAction(note: Note) -> some View {
        Button(role: .destructive) {
            note.inTrash = true
            try! context.save()
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
        .tint(.red)
    }

}

struct NotesViewPreviews: PreviewProvider {
    static var previews: some View {
        NotesView(handler: { _ in })
            .environment(\.managedObjectContext, DataController.preview.context)
    }
}
