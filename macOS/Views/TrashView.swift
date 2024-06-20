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
        predicate: NSPredicate(format: "inTrash == true"),
        animation: .default
    ) private var notes
    @State var selectedNote: Note?
    var handler: ((Note) -> Void)? = nil

    var body: some View {
        List(selection: $selectedNote) {
            ForEach(notes, id: \.self) { note in
                NoteCellView(note: note)
                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    .swipeActions(edge: .leading) {
                        restoreSwipeAction(note: note)
                    }
                    .swipeActions(edge: .trailing) {
                        deleteSwipeAction(note: note)
                    }
            }
        }
        .onChange(of: selectedNote) { oldValue, newValue in
            if let handler = handler, let newValue = newValue {
                handler(newValue)
            }
        }
        .onAppear {
            selectedNote = notes.first
        }
        .frame(minWidth: 275)
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
    
    private func deleteSwipeAction(note: Note) -> some View {
        Button(role: .destructive) {
            context.delete(note)
            try! context.save()
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
        .tint(.red)
    }

}

#Preview {
    TrashView()
}
