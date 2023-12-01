import AppKit



// MARK: tab actions
// note: we can't get the toolbar view controller to go on the responder chain when we present its view as a toolbar item.
// we define the actions here so toolbar item validation and control action dispatches work with toolbar presentation.

extension BrowserWindowController {
  
  @IBAction func addTab(_ sender: Any) {
    self.viewModel.toolbar.addNewTab()
  }
  
  @IBAction func closeTab(_ sender: NSView) {
    if let tabViewController = browserToolbarViewController?.tabCollectionViewController?.tabViewController(decendentView: sender) {
      self.viewModel.toolbar.close(tab: tabViewController.tab)
    }
  }
  
  @IBAction func activateTab(_ sender: NSView) {
    if let tabViewController = browserToolbarViewController?.tabCollectionViewController?.tabViewController(decendentView: sender) {
      self.viewModel.toolbar.activeTabId = tabViewController.tab.id
    }
  }
  
}
