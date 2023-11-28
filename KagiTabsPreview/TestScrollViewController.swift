import Cocoa



// PoC horizontal layout using stack view set up to meet hte following tricky conditions:
// - doesn't constrain size of the top frame, e.g. when there are only a few items;
// - compresses items prior to pushing out the scroll doc view
class TestScrollViewController: NSViewController {

  @IBOutlet weak var stackView: NSStackView!
    
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    updateToSameWidthConstraints(stackView.arrangedSubviews, superview: stackView)
  }
    
  var stackViewItemsTotalWidth: CGFloat {
    stackView?.arrangedSubviews.reduce(.zero) { acc, e in
      acc + e.intrinsicContentSize.width
    } ?? .zero
  }
  
  @IBAction func addButton(_ sender: Any) {
    // load up the tab v.
    let vc = TabViewController(nibName: nil, bundle: nil)
    vc.tab = Tab(label: "new tab")
    addChild(vc)

    // set up tab view for autolayout
    let tabView = vc.view
    tabView.translatesAutoresizingMaskIntoConstraints = false
    
    // add to the stack view
    stackView.addArrangedSubview(tabView)
    
    // update the same width constraints
    updateToSameWidthConstraints(stackView.arrangedSubviews, superview: stackView)
  }
}

#Preview() {
  TestScrollViewController(nibName: nil, bundle: nil)
}
