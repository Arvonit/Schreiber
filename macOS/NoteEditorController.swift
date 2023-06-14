//
//  NoteEditorController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 6/15/23.
//

import Cocoa

class NoteEditorController: NSViewController {
    
    @IBOutlet var editor: NSTextView!
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTextView()
    }
    
    func configTextView() {
        editor.font = .preferredFont(forTextStyle: .body)
        editor.string = "Welcome to Schreiber!"
        title = "Schreiber"
    }
    
}
