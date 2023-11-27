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

    self.view.addTiled(subviews: buttons)
    
    let addButton = NSButton(title: "add button", target: self, action: #selector(addButton(_:)))
    self.view.addTiled(subview: addButton)
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

