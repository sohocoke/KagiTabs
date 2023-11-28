import Cocoa


// PoC flexible-width toolbar item by using a simple width constraint.
// set up in main.storyboard.
class FlexibleToolbarItem: NSToolbarItem {
  
  var vc: TestScrollViewController?
  
  override init(itemIdentifier: NSToolbarItem.Identifier) {
    super.init(itemIdentifier: itemIdentifier)
    
//    let view = NSView(frame: .zero)
//    view.translatesAutoresizingMaskIntoConstraints = false
//    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//    view.setDebugBorder(.red)
//    self.view = view
//    
    
    // IT2 test out TestScrollViewController in toolbar.
    let vc = TestScrollViewController(nibName: nil, bundle: nil)
    self.view = vc.view
    self.vc = vc
    
    // state of flexible presentation: toolbar view can be presented wider,
    // but doesn't compress appropriately when window is made smaller.
    // view debugger reports widths of items to be ambigous (only when presented in toolbar)
    
    self.minSize.width = 50
    self.maxSize.width = 1000
  
  }
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
