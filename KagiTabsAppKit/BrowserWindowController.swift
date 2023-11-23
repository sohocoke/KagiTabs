//
//  BrowserWindowController.swift
//  KagiTabsAppKit
//
//  Created by ilo on 22/11/2023.
//

import Cocoa

class BrowserWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
      
      // inject view model into view controller..
      guard let viewController = contentViewController as? ToolbarViewController
      else { fatalError() }
      
      viewController.viewModel = ToolbarViewModel.stub
    }

}
