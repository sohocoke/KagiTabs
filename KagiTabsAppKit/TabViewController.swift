import Cocoa


/// width modes:
/// - full: when tab is active: no truncation.
///   determinants: tab 'ideal' width.
/// - compact: when (cum. width of full tabs) > (container width), render with width: (container width - active tab width) / n -1, truncate label if necessary.
///   determinants: container width, # of tabs, width of active tab
/// - minimal: when truncated label below some legible width, only render icon, subject to minimum width constraint.
///   determinants: container width, # of tabs, width of active tab, width of label
class TabViewController: NSViewController {
  var tab: Tab!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
  func updateToIdealWidth() {
    // TODO
  }
  
  func updateWidth(
    remainingContainerWidth: CGFloat,
    tabCount: Int
  ) {
    let width = remainingContainerWidth / CGFloat(tabCount)
    self.view.frame.size.width = width
  }
}


class TabView: NSView {

  @IBOutlet weak var tabButton: NSButton!
  
  override var intrinsicContentSize: NSSize {
    CGSize(width: 150, height: TabView.noIntrinsicMetric)
//    tabButton.intrinsicContentSize
  }
}


#Preview {
  let viewController = TabViewController(nibName: .init("TabView"), bundle: nil)
  viewController.tab = Tab(label: "test")
  return viewController
}
