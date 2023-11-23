import Cocoa

class BrowserWindowController: NSWindowController {
  
  let viewModel = ToolbarViewModel.stub
  
  /// view controller for the tab collection, which is presented in the toolbar, not window content.
  lazy var tabCollectionViewController: TabCollectionViewController = {
    let viewController = TabCollectionViewController(nibName: "TabCollectionViewController", bundle: nil)
    viewController.viewModel = viewModel
    return viewController
  }()
  

  // MARK: tab actions
  
  @IBAction func addTab(_ sender: Any) {
    self.viewModel.addNewTab()
  }

  @IBAction func closeTab(_ sender: NSView) {
    if let tabViewController = tabCollectionViewController.tabViewController(decendentView: sender) {
      self.viewModel.close(tab: tabViewController.tab)
    }
  }
  
  @IBAction func activateTab(_ sender: NSView) {
    if let tabViewController = tabCollectionViewController.tabViewController(decendentView: sender) {
      self.viewModel.activeTabId = tabViewController.tab.id
    }
  }
}
 
extension BrowserWindowController: NSToolbarDelegate {
  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    if itemIdentifier.rawValue == "tabCollection" {
      return TabCollectionToolbarItem(itemIdentifier: itemIdentifier, view: tabCollectionViewController.view)
    }
    if itemIdentifier.rawValue == "addressBar" {
      return AddressBarToolbarItem(itemIdentifier: itemIdentifier)
    }
    
    return NSToolbarItem(itemIdentifier: itemIdentifier)
  }
  
  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    [
      .init(rawValue: "addressBar"),
      .init(rawValue: "tabCollection"),
//      NSToolbarItem.Identifier.flexibleSpace,
      .init(rawValue: "newTab"),
    ]
  }
}
