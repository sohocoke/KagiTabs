import Cocoa

let minimalWidthThreshold: CGFloat = 50

/// width modes:
/// - full: when tab is active: no truncation.
///   determinants: tab 'ideal' width.
/// - compact: when (cum. width of full tabs) > (container width), render with width: (container width - active tab width) / n -1, truncate label if necessary.
///   determinants: container width, # of tabs, width of active tab
/// - minimal: when truncated label below some legible width, only render icon, subject to minimum width constraint.
///   determinants: container width, # of tabs, width of active tab, width of label
class TabViewController: NSViewController {
  
  @objc dynamic
  var tab: Tab {
    get {
      representedObject as! Tab
    }
    set {
      self.representedObject = newValue
    }
  }
  
  @objc dynamic
  var isActive: Bool = false
  
  
  var tabView: TabView {
    self.view as! TabView
  }
  
  
  var subscriptions: Any?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    trackCloseButtonHover()
    self.subscriptions = viewModelSubscriptions
     + viewSubscriptions
  }

  func trackCloseButtonHover() {
    let trackingArea = NSTrackingArea(
      rect: .zero,
      options: [.mouseEnteredAndExited, .inVisibleRect, .activeInActiveApp],
      owner: self,
      userInfo: ["owner": self]
    )
    tabView.closeButton.addTrackingArea(trackingArea)
    
    tabView.closeButton.alphaValue = 0
  }
  
  func untrackCloseButtonHover() {
    for trackingArea in tabView.closeButton.trackingAreas {
      if trackingArea.userInfo?["owner"] as? NSObject == self {
        tabView.closeButton.removeTrackingArea(trackingArea)
      }
    }
  }
  
  
  override func mouseEntered(with event: NSEvent) {
    tabView.closeButton.alphaValue = 1
  }
  
  override func mouseExited(with event: NSEvent) {
    tabView.closeButton.alphaValue = 0
  }
    

  func updateToIdealWidth() {
    tabView.renderMode = .normal
    tabView.invalidateIntrinsicContentSize()
  }
  
  func updateWidth(
    remainingContainerWidth: CGFloat,
    tabCount: Int
  ) {
    // squeezedWidth is that when many tabs are sharing the remaining container width.
    let squeezedWidth = remainingContainerWidth / CGFloat(tabCount)
    
    // override width only when squeezed width is less than the ideal with.
    if squeezedWidth < tabView.idealSize.width {
      tabView.renderMode =
        squeezedWidth < minimalWidthThreshold ?
        .minimal
        : .normal
    } else {
      tabView.renderMode = .normal
    }
    
    tabView.invalidateIntrinsicContentSize()
  }
  
  
  var viewModelSubscriptions: [Any] {
    [
      self.publisher(for: \.tab.label)
        .assign(to: \.tabView.tabButton.title, on: self)
    ]
  }

  var viewSubscriptions: [Any] {
    [
      // switch render mode based on available frame.
      self.publisher(for: \.view.frame)
        .sink { [unowned self] frame in
          if frame.width < minimalWidthThreshold {
            self.tabView.renderMode = .minimal
          } else {
            self.tabView.renderMode = .normal
          }
        },
    ]
  }
}


class TabView: NSView {

  @IBOutlet weak var tabButton: NSButton!
  @IBOutlet weak var closeButton: NSButton!
  @IBOutlet weak var tabButtonMinimal: NSButton!
  
  var renderMode: RenderMode = .normal {
    didSet {
      switch renderMode {
      case .normal:
        tabButton.isHidden = false
        closeButton.isHidden = false
        tabButtonMinimal.isHidden = true
      case .minimal:
        tabButton.isHidden = true
        closeButton.isHidden = true
        tabButtonMinimal.isHidden = false
      }
    }
  }
  
  enum RenderMode {
    case normal
    case minimal
  }
  
  var idealSize: CGSize {
    tabButton.intrinsicContentSize
  }
  
  var minSize: CGSize {
    tabButtonMinimal.intrinsicContentSize
  }
  
}


#Preview {
  let viewController = TabViewController(nibName: nil, bundle: nil)
  viewController.tab = Tab(label: "test")
  return viewController
}

