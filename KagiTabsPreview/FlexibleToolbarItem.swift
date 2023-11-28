import Cocoa

class FlexibleToolbarItem: NSToolbarItem {
  
  // PoC flexible-width toolbar item by using a simple width constraint.
  override init(itemIdentifier: NSToolbarItem.Identifier) {
    super.init(itemIdentifier: itemIdentifier)
    
    let view = NSView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    view.setDebugBorder(.red)
    self.view = view
    
    view.updateWidthConstraint(width: 20)
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
