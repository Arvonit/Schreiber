//
//  NoteCellView.swift
//  Commentarium
//
//  Created by Arvind on 6/8/21.
//

import Foundation
import SwiftUI

struct NoteCellView: View {
    let note: Note
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy h:mm a"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.body)
                // .lineLimit(2)
            Text(note.safeDate, formatter: dateFormatter)
                .font(.caption)
        }
    }    
}

struct NoteCellPreviews: PreviewProvider {
    static var previews: some View {
        List {
            NoteCellView(note: Note(content: "This is a test\nNew line", context: DataController.preview.context))
            NoteCellView(note: Note(content: "This is a test\nNew line", context: DataController.preview.context))
            NoteCellView(note: Note(content: "This is a test\nNew line", context: DataController.preview.context))
        }
    }
}
