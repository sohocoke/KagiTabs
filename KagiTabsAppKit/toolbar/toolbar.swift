import Cocoa



enum ToolbarIdentifiers: String {
  case browserToolbar  // address field and tabs
  
  // items inited in xib
  case newTab
  case navigateBack
}


// MARK: toolbar lifecycle

extension BrowserWindowController: NSToolbarDelegate {
  
  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    if itemIdentifier.rawValue == ToolbarIdentifiers.browserToolbar.rawValue {
      if flag {
        // the actual instance
        let toolbarItem = BrowserToolbarItem(itemIdentifier: itemIdentifier, viewModel: viewModel.toolbar)
        self.browserToolbarViewController = toolbarItem.browserToolbarViewController
        return toolbarItem
      } else {
        // the customisation palette instance
        // STUB
        let toolbarItem = BrowserToolbarItem(itemIdentifier: itemIdentifier, viewModel: viewModel.toolbar)
        return toolbarItem
      }
    }
    
    return NSToolbarItem(itemIdentifier: itemIdentifier)
  }
  
  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    [
      .init(rawValue: ToolbarIdentifiers.navigateBack.rawValue),
      .init(rawValue: ToolbarIdentifiers.browserToolbar.rawValue),
      .init(rawValue: ToolbarIdentifiers.newTab.rawValue),
    ]
  }
  
}


// MARK: item definitions

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

