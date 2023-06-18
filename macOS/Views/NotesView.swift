//
//  NotesView.swift
//  Schreiber
//
//  Created by Arvind on 6/22/23.
//

import SwiftUI

struct NotesView: View {
    // @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor<Note>(\.date)]) private var notes
    @State var selectedNotes = Set<UUID>()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()

    var body: some View {
        List(selection: $selectedNotes) {
            ForEach(notes, id: \.safeID) { note in
                VStack(alignment: .leading) {
                    Text(note.title)
                        // .bold()
                    Text(note.safeDate, formatter: dateFormatter)
                        .font(.caption)
                }
            }
        }
    }
}

struct NotesViewPreviews: PreviewProvider {
    static var previews: some View {
        NotesView()
            .environment(\.managedObjectContext, DataController.preview.context)
    }
}
