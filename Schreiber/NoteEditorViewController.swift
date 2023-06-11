//
//  NoteEditorViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit

class NoteEditorViewController: UIViewController {
    
    let note: Note?
    
    var editor: UITextView!
    
    init(note: Note? = nil) {
        self.note = note
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
    
    func configVC() {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func configTextView() {
        editor = UITextView(frame: view.bounds)
        editor.font = .preferredFont(forTextStyle: .body)
        if let note = note {
            editor.text = note.safeContent
        }
        view.addSubview(editor)
    }
    
}
