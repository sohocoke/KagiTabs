import Cocoa



class TestDynamicConstraintsViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
//    renderTestButtons()
    renderTabs()
  }
  
  func renderTestButtons() {
    // create some peer views
    let buttons = (0..<8).map {
      NSButton(title: "\($0)", target: nil, action: nil)
    }
    
    // make one wide
    let wideButton = buttons.randomElement()!
    wideButton.addConstraints(
      NSLayoutConstraint.constraints(withVisualFormat: "[button(120)]", metrics: nil, views: ["button": wideButton])
    )
    
    self.view.addTiled(subviews: buttons)
    
    let addButton = NSButton(title: "add button", target: self, action: #selector(addButton(_:)))
    self.view.addTiled(subview: addButton)
  }

  func renderTabs() {
    // create some tabs
    let tabViewControllers = ToolbarViewModel.stub.tabs.map {
      let vc = TabViewController()
      vc.tab = $0
      return vc
    }
    let tabViews = tabViewControllers.map { $0.view }
    
    // set one to active
    tabViewControllers.randomElement()!.isActive = true
    
    tabViewControllers.forEach {
      // allow compression
      $0.view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
      
      self.addChild($0)
    }
    self.view.addTiled(subviews: tabViews)
    
    // set all widths to be the same, overridable by width constraint for active
    if let firstTabVc = tabViewControllers.first {
      for tabVc in tabViewControllers[1..<tabViewControllers.count] {
        let sameWidth =           tabVc.view.widthAnchor.constraint(equalTo: firstTabVc.view.widthAnchor)
        sameWidth.identifier = "sameWidths"
        sameWidth.priority = .defaultHigh
        self.view.addConstraint(sameWidth)
      }
    }
    
    if let active = tabViewControllers.first(where: { $0.isActive }) {
      if let c = self.view.constraints.first(where: {
        $0.identifier == "sameWidths"
        && $0.firstItem as? NSView == active.view
      }) {
        c.isActive = false
      }
      active.view.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
  }
  
  @IBAction func addButton(_ sender: Any) {
    let button = NSButton(title: "close", target: self, action: #selector(removeButton(_:)))
    self.view.addTiled(subview: button)
  }
  
  @IBAction func removeButton(_ sender: NSButton) {
    self.view.removeFromTiled(subview: sender)
  }
}



#Preview {
  TestDynamicConstraintsViewController()
}

