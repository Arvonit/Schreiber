//
//  TrashView.swift
//  Schreiber
//
//  Created by Arvind on 7/2/23.
//

import SwiftUI

struct TrashView: View {
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest<Note>(
        sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)],
        predicate: NSPredicate(format: "inTrash == true")
    ) private var notes
    @State var selectedNote: Note?
    var handler: ((Note) -> Void)? = nil

    var body: some View {
        List(selection: $selectedNote) {
            ForEach(notes, id: \.self) { note in
                NoteCellView(note: note)
                    .swipeActions(edge: .leading) {
                        restoreSwipeAction(note: note)
                    }
            }
        }
        .onChange(of: selectedNote) { newValue in
            if let handler = handler {
                handler(newValue!)
            }
        }
        .onAppear {
            selectedNote = notes.first
        }
    }
    
    private func restoreSwipeAction(note: Note) -> some View {
        Button(role: .destructive) {
            note.inTrash = false
            try! context.save()
        } label: {
            Label("Restore", systemImage: "trash.slash.fill")
        }
        .tint(.purple)
    }

}

struct TrashViewPreviews: PreviewProvider {
    static var previews: some View {
        TrashView()
    }
}
