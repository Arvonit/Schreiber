//
//  Models.swift
//  Schreiber
//
//  Created by Arvind on 6/11/23.
//

import CoreData

extension Note {
    
    convenience init(
        content: String = "",
        date: Date = Date.now,
        id: UUID = UUID(),
        folder: Folder? = nil,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.content = content
        self.date = date
        self.id = id
        self.folder = folder
    }
    
    var safeContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    
    var safeDate: Date {
        get { date ?? date ?? Date() }
        set { date = newValue }
    }
    
    var safeID: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    var title: String {
        return safeContent != ""
                ? String(safeContent.split(whereSeparator: \.isNewline)[0])
                : "New note"
    }
    
    var contentWithoutTitle: String {
        let splitContent = safeContent.split(whereSeparator: \.isNewline)
        return safeContent != ""
                ? splitContent[1..<splitContent.count].joined(separator: "\n")
                : "Add some text..."
    }
    
}

extension Folder {
        
    convenience init(name: String, icon: String = "folder", context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.icon = icon
    }
    
    var safeName: String {
        get { name ?? "Unnamed folder" }
        set { name = newValue }
    }
    
    var safeIcon: String {
        get { icon ?? "folder" }
        set { icon = newValue }
    }
    
    var safeNotes: Set<Note> {
        get { notes as? Set<Note> ?? [] }
        set { notes = newValue as NSSet }
    }
    
}
