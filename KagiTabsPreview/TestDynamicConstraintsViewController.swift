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



#Preview {
  TestDynamicConstraintsViewController()
}


extension NSView {
  /// adds views as subviews laid out horizontally, vertically centred.
  /// ensure subviews have suitable vertical constraints.
  func addLine(subviews: [NSView]) {
    guard !subviews.isEmpty else { return }
    
    // prep subviews for autolayout and hug tightly.
    for subview in subviews {
      subview.translatesAutoresizingMaskIntoConstraints = false
      subview.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      
      self.addSubview(subview)
    }

    // name the constraints so we can remove them.
    
    let firstSubview = subviews[0]
    let pinLeading = firstSubview.leadingAnchor.constraint(equalTo: self.leadingAnchor)
    pinLeading.identifier = "pinLeadingViewLeading"
    let centreVertically = firstSubview.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    
    self.addConstraints([
      pinLeading, 
      centreVertically])
    
    let restSubviews = subviews[1..<subviews.count]
    guard !restSubviews.isEmpty else { return }
    var lastSubview = firstSubview
    for subview in restSubviews {
      let leadingToPriorTrailing = subview.leadingAnchor.constraint(equalToSystemSpacingAfter: lastSubview.trailingAnchor, multiplier: 1)
      let centreVertically = subview.centerYAnchor.constraint(equalTo: self.centerYAnchor)

      self.addConstraints([
        leadingToPriorTrailing,
        centreVertically
      ])

      lastSubview = subview
    }
    
    // pin trailing view trailing
    if let trailingView = subviews.last {
      repin(trailingView: trailingView)
    }

  }
  
}


extension NSView {
  func addTrailing(subview: NSView) {
    // pre-condition: there is a line of subviews.
    guard let priorTrailingSubview = self.subviews.last else {
      fatalError()
    }

    // setup layout properties for the subview.
    subview.translatesAutoresizingMaskIntoConstraints = false
    subview.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
    self.addSubview(subview)
    
    // setup constraints so subview is positioned as trailing.
    let priorTrailingToLeading = subview.leadingAnchor.constraint(equalToSystemSpacingAfter: priorTrailingSubview.trailingAnchor, multiplier: 1)
    let verticallyCentred = subview.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    self.addConstraints([
      priorTrailingToLeading,
      verticallyCentred,
    ])
    
    if let trailingView = subviews.last {
      repin(trailingView: trailingView)
    }
    
  }
  
  func repin(trailingView: NSView) {
    if let pinPriorTrailing = self.constraints.last(where: { $0.identifier
      == "pinTrailing"}) {
      self.removeConstraint(pinPriorTrailing)
    }
    
    let pinTrailing = trailingView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
    pinTrailing.identifier = "pinTrailing"
    self.addConstraint(pinTrailing)
  }

  func removeFromLine(subview: NSView) {
    let priorSubviews = subviews
    subview.removeFromSuperview()

    let i = priorSubviews.firstIndex(of: subview)
    switch i {
    case nil: fatalError()
      
    case 0:
      // repin first view
      fatalError("TODO")
      
    case priorSubviews.count - 1:
      if let trailingView = self.subviews.last {
        repin(trailingView: trailingView)
      }
      
    default:
      // obtain next view and update its leading constraint
      let priorView = self.subviews[i! - 1]
      let nextView = self.subviews[i!]
      self.addConstraint(
        nextView.leadingAnchor.constraint(equalToSystemSpacingAfter: priorView.trailingAnchor, multiplier: 1)
      )
    }
    
  }
}

