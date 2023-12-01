import Cocoa

let minimalWidthThreshold: CGFloat = 50

/// rendering variations:
/// - full: when tab is active: no truncation
///   - current implementation; normal render mode + no squish
///   -  determinants: tab 'ideal' width, active tab min width.
/// - compact: when (cum. width of full tabs) > (container width), render with width: (container width - active tab width) / n -1, truncate label if necessary.
///   - current implementation: normal render mode + squish using layout constraints
///   -  determinants: container width, # of tabs, width of active tab
/// - minimal: when truncated label below some legible width, only render icon, subject to minimum width constraint.
///   - current implementation: minimal render mode + no squish
///   - determinants: container width, # of tabs, width of active tab, width of label
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
    self.subscriptions =
      viewSubscriptions
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

  
  // MARK: mouse tracking for close button
  
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


// MARK: - data transformer for binding

@objc
class DataToNSImageTransformer: ValueTransformer {
  
  override func transformedValue(_ value: Any?) -> Any? {
    guard let data = value as? Data else {
      return NSImage(systemSymbolName: "doc", accessibilityDescription: "Empty Document")
    }
    
    return NSImage(data: data)
  }
  
  
  static let name = NSValueTransformerName(rawValue: "DataToNSImageTransformer")
  
}

var dataToNSImageTransformer: ValueTransformer = {
  let valueTransformer = DataToNSImageTransformer()
  ValueTransformer.setValueTransformer(valueTransformer, forName: DataToNSImageTransformer.name)
  return valueTransformer
}()
