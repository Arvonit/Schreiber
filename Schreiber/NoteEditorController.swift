//
//  NoteEditorController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit

class NoteEditorController: UIViewController {
    
    let note: Note
    let initialContent: String
    let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    var editor: UITextView!
    
    init(note: Note) {
        self.note = note
        self.initialContent = note.safeContent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configVC()
        configTextView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Delete if the content is empty
        // Save if there are changes
        if note.safeContent == "" {
            dataController.delete(note)
            dataController.save()
        } else if initialContent != note.safeContent {
            dataController.save()
        }
    }
    
    func configVC() {
        navigationItem.largeTitleDisplayMode = .never
        title = note.title
    }
    
    func configTextView() {
        editor = UITextView(frame: view.bounds)
        editor.font = .preferredFont(forTextStyle: .body)
        editor.text = note.safeContent
        editor.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        editor.delegate = self
        view.addSubview(editor)
    }
    
}

extension NoteEditorController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Update content of note object when text is edited
        // Also update the title of the view
        note.safeContent = textView.text
        title = note.title
    }
}
