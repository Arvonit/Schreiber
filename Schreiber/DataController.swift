//
//  DataController.swift
//  Schreiber
//
//  Created by Arvind on 6/11/23.
//

import Foundation
import CoreData
import UIKit

class DataController {
    private let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Schreiber")
        
        // Persist data to /dev/null to keep data in RAM
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Handle errors when data can not be read
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Typical reasons for an error include:
                // - The parent directory does not exist, cannot be created, or disallows writing
                // - The persistent store is not accessible, due to permissions or data protection
                //   when the device is locked
                // - The device is out of space
                // - The store could not be migrated to the current model version
                // TODO: Display an error alert to the user and send a log crash to me
                fatalError("Fatal error while loading data: \(error.localizedDescription)")
            }
        }
    }
    
    static let preview: DataController = {
        let data = DataController()
//        data.createSampleData()
        return data
    }()    
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("SAVED")
            } catch {
                // TODO: Display an error alert to the user and send a log crash to me
                fatalError("Fatal error while saving changes: \(error.localizedDescription)")
            }
        } else {
            print("NO CHANGES")
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
    func deleteAllEntities() {
        deleteAllNotes()
        deleteAllFolders()
    }
    
    func deleteAllNotes() {
        // Fetch and delete all notes
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let batchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.executeAndMergeChanges(using: batchRequest)
        } catch {
            fatalError("Fatal error while deleting all notes: \(error.localizedDescription)")
        }
    }
    
    func deleteAllFolders() {
        // Fetch and delete all folders
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Folder")
        let batchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.executeAndMergeChanges(using: batchRequest)
        } catch {
            fatalError("Fatal error while deleting all folders: \(error.localizedDescription)")
        }
    }
        
    func createSampleData() {
        // Sample notes
        let notes: [String] = [
            """
            Hello, world!
            Hello, user! Welcome to Schreiber! This is the first note created. Feel free to explore the other notes and around the app.
            """,
            """
            Write down your ideas!
            Schreiber is the best way to capture your thoughts, store your notes, and sync them across the devices.
            """,
            """
            Journal
            Today, I woke up pretty late at 1:00 PM. I didn't really do much other than eating and watching Netflix.
            """,
            """
            A trashed note
            This note should be in the trash.
            """,
            """
            An untagged note
            This note should be untagged.
            """
        ]
        
        // Sample folders
        let folders: [Folder] = [
            Folder(name: "Blog", context: context),
            Folder(name: "Ideas", context: context),
            Folder(name: "Journal", context: context)
        ]
        
        // Create sample notes and relate them to folders
        for i in 0..<3 {
            let _ = Note(content: notes[i], folder: folders[i], context: context)
        }
        
        // Attempt to save sample data to the managed object context
        do {
            try context.save()
        } catch {
            fatalError("Fatal error while creating sample data: \(error.localizedDescription)")
        }
    }
}

