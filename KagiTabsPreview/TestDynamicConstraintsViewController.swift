import Cocoa


// PoC equal-width views that don't depend on any explicit size computation.
// set up in preview target's view controller.
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
    
    self.view.addTiled(subviews: tabViews)
    
    tabViewControllers.forEach {
      self.addChild($0)
    }

    
    // TODO refactor constraints etc for reuse
    let activeView = tabViewControllers.first { $0.isActive }!.view
    let inactiveViews = tabViewControllers.filter { $0.view != activeView }.map { $0.view }
    allowCompression(inactiveViews, except: activeView)
    
    updateToEqualWidthConstraints(inactiveViews, superview: self.view)
    
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


