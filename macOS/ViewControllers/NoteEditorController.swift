//
//  NoteEditorController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 7/2/23.
//

import Cocoa
import SwiftUI

class NoteEditorController: NSViewController {
    
    private let note: Note
    private let initialContent: String
    private let dataController = (NSApplication.shared.delegate as! AppDelegate).controller
    
    private lazy var scrollView = NSTextView.scrollableTextView()
    private lazy var editor = scrollView.documentView as! NSTextView
    
    init(note: Note) {
        self.note = note
        self.initialContent = note.safeContent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editor.textContainerInset = NSSize(width: 8, height: 12)
        editor.font = .preferredFont(forTextStyle: .body)
        editor.string = note.safeContent
        editor.delegate = self
        
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: 275)
        ])
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        // Delete if the content is empty
        // Save if there are changes
        if note.safeContent == "" {
            dataController.delete(note)
            dataController.save()
        } else if initialContent != note.safeContent {
            note.date = Date.now
            dataController.save()
        }
    }
    
}

extension NoteEditorController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        // print(notification)
        note.content = editor.string
    }
}

struct NoteEditorPreviews: PreviewProvider {
    static let exampleNote = Note(content: "Example note\n\nThis is a really cool document.",
                                  context: DataController.preview.context)
    
    static var previews: some View {
        ViewControllerPreview {
            NoteEditorController(note: exampleNote)
        }
    }
}
