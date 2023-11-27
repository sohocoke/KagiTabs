import AppKit



extension NSView {
  
  /// adds views as subviews laid out horizontally, vertically centred.
  /// ensure subviews have suitable vertical constraints.
  func addTiled(subviews: [NSView]) {
    guard !subviews.isEmpty else { return }

    // prep subviews for autolayout.
    for subview in subviews {
      subview.translatesAutoresizingMaskIntoConstraints = false
      
      // content items should hug tightly so total width is accurate.
      subview.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    updateToSubviews(subviews)
  }
  
  func addTiled(subview: NSView) {
    assert(!self.subviews.contains(subview))
    
    addTiled(subviews: self.subviews + [subview])
  }
  
  func removeFromTiled(subview: NSView) {
    let newSubviews = self.subviews.filter { $0 != subview }
    updateToSubviews(newSubviews)
  }
  
  
  func updateToSubviews(_ subviews: [NSView]) {
    let toRemove = self.subviews.filter { !subviews.contains($0) }

    // update subviews
    
    for view in toRemove {
      view.removeFromSuperview()
    }
    for view in subviews {
      if view.superview != self {
        self.addSubview(view)
      }
    }

    // generate and replace the constraints

    let tiledSubviewsFormat = subviews.enumerated().map { i, _ in
      "[subview_\(i)]"
    }.joined(separator: "-")
    let viewDict = Dictionary(uniqueKeysWithValues: subviews.enumerated().map { i, view in
      ("subview_\(i)", view)
    })
    let layoutFormat = "|-0-\(tiledSubviewsFormat)-0-|"
    
    let tileConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: layoutFormat,
      metrics: nil,
      views: viewDict
    )
    + subviews.map {
      $0.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    }
        
    self.removeConstraints(self.constraints)
    self.addConstraints(tileConstraints)
  }

}
