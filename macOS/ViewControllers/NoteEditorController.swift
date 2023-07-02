//
//  NoteEditorController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 7/2/23.
//

import Cocoa

class NoteEditorController: NSViewController {
    
    private let note: Note
    
    private let dataController = (NSApplication.shared.delegate as! AppDelegate).controller
    private lazy var scrollView = NSTextView.scrollableTextView()
    private lazy var editor = scrollView.documentView as! NSTextView
    
    init(note: Note) {
        self.note = note
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
    }
    
}

extension NoteEditorController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        print(notification)
    }
}
