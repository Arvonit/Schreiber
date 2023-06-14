//
//  ViewController.swift
//  Schreiber
//
//  Created by Arvind on 6/14/23.
//

import Cocoa
import SwiftUI

class ViewController: NSSplitViewController {

    override func viewWillAppear() {
        super.viewWillAppear()
        // sidebarItem.viewController = NSViewController()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

struct Preview: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            ViewController()
        }
    }
}
