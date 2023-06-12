//
//  NoteEditorController.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import UIKit

class NoteEditorController: UIViewController {
    
    let note: Note?
    let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let note = note else { return }
//        note.safeContent = editor.text
//        if editor.text != "" && note.safeContent != editor.text {
        note.safeContent = editor.text
        dataController.save()
//        } else {
//            dataController.delete(note)
//        }
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
