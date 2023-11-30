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
    
    // thse size properties are deprecated as of macOS12.
    // since we're targetting macOS11, just use them for now, in favour of auto layout constraints
    // that work with all the width variations in the toolbar -- they turned out to be v tricky.
    self.minSize.width = 150
    self.maxSize.width = 15000
  }
}

