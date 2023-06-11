//
//  TripleColumnViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/11/23.
//

import UIKit

class TripleColumnViewController: UISplitViewController {
    
    override init(style: UISplitViewController.Style = .tripleColumn) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configVC()
    }
    
    func configVC() {
        // Add lists to split view
        setViewController(FoldersViewController(), for: .primary)
        setViewController(NotesViewController(), for: .supplementary)
        setViewController(NoteEditorViewController(), for: .secondary)

        // Specify titles for views
        viewController(for: .primary)?.title = "Schreiber"
        viewController(for: .supplementary)?.title = "Folder"
        
        // Use large titles in lists
        viewController(for: .primary)?.navigationController?.navigationBar.prefersLargeTitles = true
        viewController(for: .supplementary)?.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
}

#Preview {
    TripleColumnViewController()
}
