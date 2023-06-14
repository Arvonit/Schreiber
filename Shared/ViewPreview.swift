//
//  ViewPreview.swift
//  Schreiber
//
//  Created by Arvind on 6/14/23.
//

import SwiftUI

#if os(iOS)
struct ViewPreview<View: UIView>: UIViewRepresentable {
    let view: View
    
    init(_ builder: @escaping () -> View) {
        view = builder()
    }
    
    // MARK: UIViewRepresentable
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
#elseif os(macOS)
struct ViewPreview<View: NSView>: NSViewRepresentable {
    let view: View
    
    init(_ builder: @escaping () -> View) {
        view = builder()
    }
    
    // MARK: NSViewRepresentable
    func makeNSView(context: Context) -> NSView {
        return view
    }
    
    func updateNSView(_ view: NSView, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
#endif
