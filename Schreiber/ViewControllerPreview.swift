//
//  ViewControllerPreview.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import SwiftUI

struct ViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }
    
    // MARK: - UIViewControllerRepresentable
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }

    func makeUIViewController(context: Context) -> ViewController {
        viewController
    }
}
