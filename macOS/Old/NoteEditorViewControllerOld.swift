//
//  NoteEditorController.swift
//  Schreiber (macOS)
//
//  Created by Arvind on 6/15/23.
//

import Cocoa

class NoteEditorViewControllerOld: NSViewController {

    @IBOutlet var editor: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configConstraints()
        configTextView()
    }

    func configConstraints() {
        view.translatesAutoresizingMaskIntoConstraints = false
        // view.addConstraints([
        //     NSLayoutConstraint(
        //         item: view,
        //         attribute: .width,
        //         relatedBy: .equal,
        //         toItem: nil,
        //         attribute: .notAnAttribute,
        //         multiplier: 1,
        //         constant: 400
        //     )
        // ])
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
    }

    func configTextView() {
        editor.textContainerInset = NSSize(width: 8, height: 12)
        editor.font = .preferredFont(forTextStyle: .body)
        editor.string = "Welcome to Schreiber!"
        title = "Schreiber"
    }

}
