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
    
    self.minSize.width = 150
    self.maxSize.width = 15000

//    // let's see if these constraints work as equivalents to setting min / max size
//    self.view?.updateWidthConstraint(width: 150)
//    
//    if let c =
//        self.view?.widthAnchor.constraint(lessThanOrEqualToConstant: 15000) {
//      self.view?.addConstraint(c)
//    }
  }
}
extension BrowserToolbarItem: NSToolbarDelegate {
  
}

extension NSView {
  func updateWidthConstraint(width: CGFloat) {
    let constraints = NSLayoutConstraint.constraints(withVisualFormat: "[view(>=\(width))]", metrics: nil, views: ["view": self])
    for c in constraints {
      c.identifier = "toolbarWidth"
    }
    self.removeConstraints(self.constraints.filter { $0.identifier == "tooblarWidth"})
    self.addConstraints(constraints)
  }
}


