import Cocoa

class TestDynamicConstraintsViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // create some peer views
    let buttons = (0..<8).map {
      NSButton(title: "\($0)", target: nil, action: nil)
    }
    
    // make one wide
    let wideButton = buttons.randomElement()!
    wideButton.addConstraints(
      NSLayoutConstraint.constraints(withVisualFormat: "[button(120)]", metrics: nil, views: ["button": wideButton])
    )

    self.view.addLine(subviews: buttons)
    
    let addButton = NSButton(title: "add button", target: self, action: #selector(addButton(_:)))
    self.view.addTrailing(subview: addButton)
  }
  
  @IBAction func addButton(_ sender: Any) {
    let button = NSButton(title: "close", target: self, action: #selector(removeButton(_:)))
    self.view.addTrailing(subview: button)
  }
  
  @IBAction func removeButton(_ sender: NSButton) {
    self.view.removeFromLine(subview: sender)
  }
}

extension NSView {
  func addTrailing(subview: NSView) {
    // pre-condition: there is a line of subviews.
    guard let priorTrailingSubview = self.subviews.last else {
      fatalError()
    }

    // deprioritise constraint that pins trailng edge of last subview
    // relies on the order of the anchors in constraint, so ensure the line rendering setup respects this order when building constraints.
    self.constraints.filter {
      $0.firstAnchor == self.trailingAnchor
      && $0.secondAnchor == priorTrailingSubview.trailingAnchor
    }
    .forEach {
      $0.priority = .defaultHigh
    }
    
    // setup layout properties for the subview.
    subview.translatesAutoresizingMaskIntoConstraints = false
    subview.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
    subview.setContentCompressionResistancePriority(.required, for: .horizontal)  // temp
    
    self.addSubview(subview)
    
    // setup constraints so subview is positioned as trailing.
    let priorTrailingToLeading = subview.leadingAnchor.constraint(equalToSystemSpacingAfter: priorTrailingSubview.trailingAnchor, multiplier: 1)
    let trailingPinnedToSuperview = self.trailingAnchor.constraint(equalTo: subview.trailingAnchor)
    let verticallyCentred = priorTrailingSubview.centerYAnchor.constraint(equalTo: subview.centerYAnchor)
    self.addConstraints([
      priorTrailingToLeading,
      trailingPinnedToSuperview,
      verticallyCentred,
    ])
  }
  
  func removeFromLine(subview: NSView) {
    // TODO
    
    subview.removeFromSuperview()
  }
}

#Preview {
  TestDynamicConstraintsViewController()
}
