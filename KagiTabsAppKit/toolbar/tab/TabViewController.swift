import Cocoa

/// when width becomes less than this threshold, switch to 'minimal' mode.
let minimalWidthThreshold: CGFloat = 60

let defaultFaviconImage = NSImage(systemSymbolName: "doc", accessibilityDescription: "Tab")!
let faviconImageSize = CGSize(width: 16, height: 16)

let activeTabBackgroundColour = NSColor.white.cgColor
let activeTabCornerRadius = 5.0
let activeTabShadowBlurRadius = 5.0
let activeTabShadowOffset = CGSize(width: 0, height: -2)


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
  
  @IBOutlet weak var separator: NSBox!
  
  var subscriptions: Any?
  
  
  // MARK: view lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    trackCloseButtonHover()

    self.view.setupBackgroundLayerAndShadow()

    self.subscriptions =
      viewSubscriptions
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()

    self.view.scaleFromCentre()
    
    // disabling the button's border also  disables hover highlight.
    // work around by configuring button to show border when mouse inside.
    self.tabView.tabButton.showsBorderOnlyWhileMouseInside = true
    
//    self.view.setDebugBorder(.purple)  // DEBUG
  }

  
  // MARK: subscriptions
  
  var viewSubscriptions: [Any] {
    [
      // switch render mode based on available frame.
      self.publisher(for: \.view.frame)
        .sink { [unowned self] frame in
          if frame.width > minimalWidthThreshold {
            self.tabView.renderMode = .normal
          } else {
            self.tabView.renderMode = .minimal
          }
        },
      
      // update background view and button visibility when active status changes.
      self.publisher(for: \.isActive, options: [.initial, .new])
        .sink { [weak self] isActive in
          guard let backgroundView = self?.view.subviews.first(where: { $0 is BackgroundRoundRectView })
          else { return }
          backgroundView.isHidden = !isActive
          
          self?.tabView.tabButton.isHidden = isActive
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
    
    // close button owns tracking area for hover detection,
    // so mustn't be hidden.
    // control presentation using alpha value instead.
    tabView.closeButton.alphaValue = 0
  }
  
  func untrackCloseButtonHover() {
    for trackingArea in tabView.closeButton.trackingAreas {
      if trackingArea.userInfo?["owner"] as? NSObject == self {
        tabView.closeButton.removeTrackingArea(trackingArea)
      }
    }
  }
  
  @objc dynamic
  var isHoveredOnCloseButton: Bool = false {
    didSet {
      tabView.closeButton.alphaValue = isHoveredOnCloseButton ? 1 : 0
    }
  }
  
  override func mouseEntered(with event: NSEvent) {
    self.isHoveredOnCloseButton = true
  }
  
  override func mouseExited(with event: NSEvent) {
    self.isHoveredOnCloseButton = false
  }
      
  @objc dynamic
  var faviconImage: NSImage? {
    let image = tab.faviconImageData.flatMap ({ NSImage(data: $0) })
      ?? defaultFaviconImage

    if isHoveredOnCloseButton {
      let blankImage = NSImage(size: image.size, flipped: false) { rect in
        NSColor.clear.set()
        rect.fill()
        return true
      }
      return blankImage
    }
    
    image.size = faviconImageSize
    
    return image
  }
  
  override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
    switch key {
    case "faviconImage":
      return [
        "tab.faviconImageData",
        "isHoveredOnCloseButton",
      ]
    default:
      return super.keyPathsForValuesAffectingValue(forKey: key)
    }
  }
}


class TabView: NSView {

  @IBOutlet weak var tabButton: NSButton!
  @IBOutlet weak var closeButton: NSButton!
  @IBOutlet weak var tabButtonMinimal: NSButton!
  @IBOutlet weak var label: NSTextField!
  @IBOutlet weak var faviconImage: NSImageView!

  @IBOutlet weak var faviconImageLeading: NSLayoutConstraint!
  @IBOutlet weak var faviconImageTrailingToLabelLeading: NSLayoutConstraint!
  @IBOutlet weak var labelTrailing: NSLayoutConstraint!

  var renderMode: RenderMode = .normal {
    didSet {
      switch renderMode {
      case .normal:
        label.isHidden = false
        faviconImage.isHidden = false
        closeButton.isHidden = false
        tabButtonMinimal.isHidden = true
      case .minimal:
        label.isHidden = true
        faviconImage.isHidden = true
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
    let width = faviconImageLeading.constant
      + faviconImage.fittingSize.width
      + faviconImageTrailingToLabelLeading.constant
      + label.intrinsicContentSize.width
      + labelTrailing.constant

    let height = label.frame.height
    return CGSize(width: width, height: height)
  }
  
  var minSize: CGSize {
    tabButtonMinimal.intrinsicContentSize
  }
  
}


#Preview {
  _ = valueTransformers
  let viewController = TabViewController(nibName: nil, bundle: nil)
  viewController.tab = Tab(label: "test")
  return viewController
}



extension NSView {
  /// adds a subview which renders a round rect and a shadow,
  /// which adapts to the view's size.
  func setupBackgroundLayerAndShadow() {
    let view = BackgroundRoundRectView()
    
    self.addSubview(view, positioned: .below, relativeTo: nil)
    
    // width, height, position constraints
    view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 0).isActive = true
    view.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 0).isActive = true
    view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
}

class BackgroundRoundRectView: NSView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    let view = self
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let rectLayer = rectLayer()
    rectLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    view.layer = rectLayer
    
    // setting up the shadow on the topmost layer does not work;
    // set it up on the view instead.
    let shadow = NSShadow()
    shadow.shadowBlurRadius = activeTabShadowBlurRadius
    shadow.shadowOffset = activeTabShadowOffset
    view.shadow = shadow
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

func rectLayer() -> CALayer {
  let rect = CALayer()
  rect.backgroundColor = activeTabBackgroundColour
  rect.cornerRadius = activeTabCornerRadius
  rect.anchorPoint = .init(x: 0.5, y: 0.5)
  
  return rect
}


