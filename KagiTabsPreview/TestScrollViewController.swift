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
    let button = NSButton(title: "new button", target: nil, action: nil)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    stackView.addArrangedSubview(button)
    
    let stackViewSubviews = stackView.arrangedSubviews
    updateToSameWidthConstraints(stackViewSubviews, superview: stackView)
  }
}

#Preview() {
  TestScrollViewController(nibName: nil, bundle: nil)
}
