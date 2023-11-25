import Cocoa


class BrowserToolbarItem: NSToolbarItem {
  var browserToolbarViewController: BrowserToolbarViewController
  
  init(itemIdentifier: NSToolbarItem.Identifier, viewModel: ToolbarViewModel) {
    guard let browserToolbarViewController = NSStoryboard(name: .init("BrowserToolbar"), bundle: nil)
      .instantiateInitialController() as? BrowserToolbarViewController
    else { fatalError() }
    
    browserToolbarViewController.viewModel = viewModel

    self.browserToolbarViewController = browserToolbarViewController
    super.init(itemIdentifier: itemIdentifier)

    self.view = browserToolbarViewController.view
    
    self.label = "Address and Tabs"
    self.paletteLabel = "Address and Tabs"
  }
}


class BrowserToolbarViewController: NSViewController {
  
  var tabCollectionViewController: TabCollectionViewController? {
    didSet {
      tabCollectionViewController?.viewModel = viewModel
    }
  }
  
  var viewModel: ToolbarViewModel? {
    didSet {
      tabCollectionViewController?.viewModel = viewModel
    }
  }
  

  // MARK: storyboard lifecycle
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let tabCollectionViewController = segue.destinationController as? TabCollectionViewController {
      self.tabCollectionViewController = tabCollectionViewController
    }
  }

}
