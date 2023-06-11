//
//  NoteEditorViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit

class NoteEditorViewController: UIViewController {
    
    var editor: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTextView()
    }
    
    func configTextView() {
        editor = UITextView(frame: view.bounds)
        view.addSubview(editor)
        editor.font = .preferredFont(forTextStyle: .body)
    }
    
}
