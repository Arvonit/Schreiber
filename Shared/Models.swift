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
        folder: Folder? = nil,
        inTrash: Bool = false,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.content = content
        self.date = date
        self.id = UUID()
        self.folder = folder
        self.inTrash = inTrash

        try! context.obtainPermanentIDs(for: [self])
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
        self.id = UUID()
        self.name = name
        self.icon = icon
        
        try! context.obtainPermanentIDs(for: [self])
    }
    
    var safeName: String {
        get { name ?? "Unnamed folder" }
        set { name = newValue }
    }
    
    var safeIcon: String {
        get { icon ?? "folder" }
        set { icon = newValue }
    }
    
    var safeID: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    var safeNotes: Set<Note> {
        get { notes as? Set<Note> ?? [] }
        set { notes = newValue as NSSet }
    }
    
}

struct NoteGroup: Hashable {
    let name: String
    let icon: String
    
    private init(name: String, icon: String) {
        self.name = name
        self.icon = icon
    }
    
    static let allNotes = NoteGroup(name: "All Notes", icon: "tray.full")
    static let trash = NoteGroup(name: "Trash", icon: "trash")
}

enum SidebarItem: Hashable {
    case group(NoteGroup)
    case folder(NSManagedObjectID)
}

enum SidebarSection: Int, CaseIterable {
    case groups
    case folders
}
