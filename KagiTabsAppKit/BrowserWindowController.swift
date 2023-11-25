import Cocoa



class BrowserWindowController: NSWindowController {
  
  let viewModel = ToolbarViewModel.stub
  
  var browserToolbarViewController: BrowserToolbarViewController?
  
  // MARK: tab actions
  // note: we can't get the toolbar view controller to go on the responder chain when we present its view as a toolbar item.
  // we define the actions here so toolbar item validation and control action dispatches work with toolbar presentation.
  
  @IBAction func addTab(_ sender: Any) {
    self.viewModel.addNewTab()
  }

  @IBAction func closeTab(_ sender: NSView) {
    if let tabViewController = browserToolbarViewController?.tabCollectionViewController?.tabViewController(decendentView: sender) {
      self.viewModel.close(tab: tabViewController.tab)
    }
  }
  
  @IBAction func activateTab(_ sender: NSView) {
    if let tabViewController = browserToolbarViewController?.tabCollectionViewController?.tabViewController(decendentView: sender) {
      self.viewModel.activeTabId = tabViewController.tab.id
    }
  }

}
 
extension BrowserWindowController: NSToolbarDelegate {
  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    if itemIdentifier.rawValue == ToolbarIdentifiers.browserToolbar.rawValue {
      if flag {
        // the actual instance
        let toolbarItem = BrowserToolbarItem(itemIdentifier: itemIdentifier, viewModel: viewModel)
        self.browserToolbarViewController = toolbarItem.browserToolbarViewController
        return toolbarItem
      } else {
        // the customisation palette instance
        // STUB
        let toolbarItem = BrowserToolbarItem(itemIdentifier: itemIdentifier, viewModel: viewModel)
        return toolbarItem
      }
    }
    
    return NSToolbarItem(itemIdentifier: itemIdentifier)
  }
  
  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    [
      // programmatically inited toolbar items
      .init(rawValue: "browserToolbar"),
      
      // items inited in xib
      .init(rawValue: "newTab"),
    ]
  }
}

enum ToolbarIdentifiers: String {
  case browserToolbar
}
