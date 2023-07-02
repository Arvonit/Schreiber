//
//  RootViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/11/23.
//

import UIKit
import SwiftUI

class RootViewController: UISplitViewController {
    
    init() {
        super.init(style: .tripleColumn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configVC()
    }
    
    func configVC() {
        // Blur the sidebar background on macOS
        primaryBackgroundStyle = .sidebar
        
        // Add lists to split view
        setViewController(SidebarViewController(), for: .primary)
        setViewController(makePlaceholderVC("Select a folder"), for: .supplementary)
        setViewController(makePlaceholderVC("Select a note"), for: .secondary)
        
        // Make folders view top of navigation stack for iPhone
        setViewController(UINavigationController(rootViewController: SidebarViewController()),
                          for: .compact)
    }
    
    func makePlaceholderVC(_ text: String) -> UIViewController {
        let vc = UIViewController()
        let label = UILabel()
        vc.view.addSubview(label)
        label.text = text
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        vc.view.backgroundColor = .systemBackground
        return vc
    }
    
}

struct RootViewPreviews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            RootViewController()
                .makePlaceholderVC("Test")
        }
    }
}
