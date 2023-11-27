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
      if $0.isActive {
        $0.view.setContentCompressionResistancePriority(.required, for: .horizontal)
      } else {
        // allow compression
        $0.view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
      }

      self.addChild($0)
    }
    
    self.view.addTiled(subviews: tabViews)
    
    let inactiveViews = tabViewControllers.filter { !$0.isActive }
      .map { $0.view }
    
    let widthConstraints = {
      if let firstView = inactiveViews.first {
        return inactiveViews[1..<inactiveViews.count].map {
          let c = $0.widthAnchor.constraint(equalTo: firstView.widthAnchor)
          c.priority = .defaultLow
          c.identifier = "sameWidths"
          return c
        }
      }
      return []
    }()
    self.view.addConstraints(widthConstraints)
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

