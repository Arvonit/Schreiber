//
//  ViewControllerPreview.swift
//  Schreiber
//
//  Created by Arvind on 6/10/23.
//

import SwiftUI

#if os(iOS) || os(visionOS)
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
#elseif os(macOS)
struct ViewControllerPreview<ViewController: NSViewController>: NSViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }
    
    // MARK: - UIViewControllerRepresentable
    func updateNSViewController(_ nsViewController: ViewController, context: Context) {
    }

    func makeNSViewController(context: Context) -> ViewController {
        viewController
    }
}
#endif
