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
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            // Text(note.safeDate, formatter: dateFormatter)
            //     .font(.subheadline)
            Text(note.title)
                .font(.headline)
                .lineLimit(2)
            Text(note.safeDate, formatter: dateFormatter)
                .font(.subheadline)
            // Text(note.contentWithoutTitle)
            //     .font(.callout)
            //     .lineLimit(3)
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
