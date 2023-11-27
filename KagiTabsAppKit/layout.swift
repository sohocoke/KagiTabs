import AppKit



extension NSView {
  /// adds views as subviews laid out horizontally, vertically centred.
  /// ensure subviews have suitable vertical constraints.
  func addLine(subviews: [NSView]) {
    
    // prep subviews for autolayout and hug tightly.
    for subview in subviews {
      subview.translatesAutoresizingMaskIntoConstraints = false
      subview.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      
      self.addSubview(subview)
    }

    let viewDict = Dictionary(uniqueKeysWithValues: subviews.enumerated().map { i, button in
      ("subview_\(i)", button)
    })
    let subviewsFormatString = subviews.enumerated().map { i, _ in
      "[subview_\(i)]"
    }.joined(separator: "-")
    let formatString = "|-0-\(subviewsFormatString)"
      
    self.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: formatString,
        options: [.alignAllCenterY],
        metrics: nil,
        views: viewDict)
    )
    
    let lastSubview = subviews.last!
    
    let pinLastViewToTrailingEdge = self.trailingAnchor.constraint(equalTo: lastSubview.trailingAnchor)
    pinLastViewToTrailingEdge.priority = .defaultHigh
//    pinLastViewToTrailingEdge.identifier = "lastSubviewPinnedToTrailingEdge"
    let centreVerticallyInSuperview = self.centerYAnchor.constraint(equalTo: lastSubview.centerYAnchor)
    
    self.addConstraints([
      pinLastViewToTrailingEdge,
      centreVerticallyInSuperview,
    ])
  }
}


