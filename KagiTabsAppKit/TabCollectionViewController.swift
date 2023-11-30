import Cocoa
import Combine



// use some constants for width to simplify the logic,
// can elaborate later.
let activeTabMinWidth: CGFloat = 140
let inactiveTabMaxWidth: CGFloat  = 120



/// wow. we went deeeep into the autolayout cave.
///
/// tried the following tactics:
/// - use a stack view, make intrinsicContentSize overrides at stretegic junctures
/// - use a tiling strategy in a plain old NSView, to make precise computations
/// - go back to a stack view configured to allow for computation based on items only,
///     move away from intrinsicContentSize and perform width computation for various scenarios
///
/// I think we hit the spec now.
/// But should there be a need to iterate, I'd consider:
/// - go back to using intrinsicContentSize with precise invalidation based on tab content change
/// - look at reducing constraints by more dynamically modifying comp resistance priorities
class TabCollectionViewController: NSViewController {

  @objc dynamic
  var viewModel: ToolbarViewModel? {
    get {
      representedObject as? ToolbarViewModel
    }
    set {
      self.representedObject = newValue
    }
  }
  
  @IBOutlet weak var tabsStackView: NSStackView!
  @IBOutlet @objc dynamic weak var tabsScrollView: NSScrollView!
  @IBOutlet weak var scrollDocumentView: NSView!
  
  var subscriptions: Any?
  
  
  // MARK: initialisers

  required init?(coder: NSCoder) {
    super.init(nibName: nil, bundle: nil)
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  
  // MARK: view lifecycle
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    // clear placeholder views from stack view.
    tabsStackView.arrangedSubviews.forEach {
      tabsStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    
    self.subscriptions =
      viewModelSubscriptions
      + viewSubscriptions
    
  }
  
  override func viewWillDisappear() {
    self.subscriptions = nil
    
    super.viewWillDisappear()
  }
    
  
  // MARK: tab sizing
  
  func updateTabSizes(animate: Bool = true) {
    guard let activeView = activeTabViewController?.tabView
    else { return }
    
    let inactiveViews = tabViewControllers.filter {
      $0.view != activeView
    }.map { $0.tabView }
    
    guard inactiveViews.count > 0
    else { return }
    
    // ** use width constraints and compression resistance.
    
    allowCompression(inactiveViews, except: activeView)
    
    // obtain / compute important lengths for constraint setup.
    
    let availableWidth = view.frame.width
    
    let activeItemWidth = max(
      activeView.idealSize.width,
      activeTabMinWidth  // avoid tiny active tabs.
    )
    
    let availableInactiveWidth = max(
      availableWidth - activeItemWidth,
      0  // disallow negative width.
    )
    let inactiveTabSquishLowLimit = inactiveViews[0].minSize.width  // max-squish limit.
    
    // absolute minimum width of the scrollable content.
    let totalMinWidth = inactiveTabSquishLowLimit * CGFloat(inactiveViews.count) + activeItemWidth
    
    // inactive tabs are of equal widths and capped.
    // to use in need-squish.
    var inactiveTabComputedWidth =  availableInactiveWidth / CGFloat(inactiveViews.count)
    
    inactiveTabComputedWidth = max(inactiveTabComputedWidth, inactiveTabSquishLowLimit)  // floor it at inactiveTabSquishLowLimit
    
    // sometimes we have plenty of space, letting us avoid capping any widths.
    let totalIdealWidth = activeItemWidth + inactiveViews.reduce(.zero) { acc, e in
      let widthWanted = max(
        e.idealSize.width,
        inactiveTabMaxWidth  // avoid tiny inactive tabs
      )
      return acc + widthWanted
    }
    
    // break out to 3 cases.
    enum LayoutCase {
      case noSquish
      case needSquish
      case needScroll
    }
    let layoutCase: LayoutCase
    
    // when there's enough room to present everything, we're in no-squish territory.
    if totalIdealWidth < availableWidth {
      layoutCase = .noSquish
    }
    // when we minimise everything but it still doesn't fit, we're in need-scroll territory.
    else if totalMinWidth >= availableWidth {
      layoutCase = .needScroll
    }
    else {
      layoutCase = .needSquish
    }
    
    // install the constraints.
    (inactiveViews + [activeView]).forEach { view in
      
      let isActive = view == activeView
      
      // set width for active tab, so it's always presented prominently.
      let activeWidthC = constraint(view: view, id: "activeWidth", init: {
        view.widthAnchor.constraint(equalToConstant: activeItemWidth)
      })
      
      // secure minimal widths for inactive tabs except in .needScroll, to avoid tiny tabs.
      let inactiveMinWidthC = constraint(view: view, id: "inactiveMinWidth", 
                                         priority: .defaultLow - 1,  // allow compression.
                                         init: {
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: inactiveTabMaxWidth)
      })
        
      // on .needSquish, cap inactive tab widths to computed.
      let inactiveWidthC = constraint(view: view, id: "inactiveWidth", 
                                      priority: .defaultHigh,
                                      init: {
        view.widthAnchor.constraint(equalToConstant: inactiveTabComputedWidth)
      })
        
      // on .needScroll, constrain inactive tab width to minimal width,
      // since scrolling requires minimal inactive tabs.
      let maxSquishWidthC = constraint(view: view, id: "maxSquishWidth", init: {
        view.widthAnchor.constraint(equalToConstant: inactiveTabSquishLowLimit)
      })
      
      switch (isActive, layoutCase) {
      case (true, _):
        NSLayoutConstraint.activate([activeWidthC])
        
      // rest is for inactive tab cases.
      case (_, .noSquish):
        NSLayoutConstraint.activate([
          inactiveMinWidthC,
        ])
      case (_, .needSquish):
        NSLayoutConstraint.activate([
          inactiveMinWidthC,
          inactiveWidthC,
        ])
      case (_, .needScroll):
        NSLayoutConstraint.activate([
          maxSquishWidthC
        ])
      }
    }
    
    // update scrollability based on the layout case.
    switch layoutCase {
    case .noSquish:
      // turn on the no-op scroll.
      self.isScrollable = true
      
    case .needScroll:
      self.isScrollable = true
      
    case .needSquish:
      self.isScrollable = false
    }
      
    if animate {
      NSAnimationContext.runAnimationGroup { context in
        context.allowsImplicitAnimation = true
        
        view.animator().layoutSubtreeIfNeeded()
      }
    }
  }
  
  var isScrollable: Bool = false {
    didSet {
      // when scrollable, don't pin the stackview.
      let shouldPinStackViewWidthToFrame = !isScrollable
      
      constraint(view: view, id: "tabsStackWidthPinnedToFrame") {
        tabsStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
      }
      .isActive = shouldPinStackViewWidthToFrame
    }
  }
  
  
  // MARK: kvo
  
  var viewModelSubscriptions: [Any] {
    [
      self.publisher(for: \.viewModel?.tabs)
        .map { [unowned self] tabs in
          let tabs = tabs ?? []
          let prior = self.children.compactMap {
            ($0 as? TabViewController)?.tab
          }
          
          let oldTabIds = prior.map { $0.id }
          let newTabIds = tabs.map { $0.id }

          let added = tabs.filter { !oldTabIds.contains($0.id) }
          let removed = prior.filter { !newTabIds.contains($0.id) }
          return (added, removed)
        }
        .sink { [unowned self] added, removed in
        
          let tabViewControllersToRemove = tabViewControllers.filter { vc in
            removed.contains { $0.id == vc.tab.id }
          }
          let tabViewControllersToAdd = added.map {
            newTabViewController(tab: $0)
          }
          
          // take out the removed tabs
          tabViewControllersToRemove.forEach { vc in
            NSAnimationContext.runAnimationGroup { context in
              vc.view
                .animator()
                .alphaValue = 0
              
              // remove early, so tab count is correct for size computation
              vc.removeFromParent()
            } completionHandler: {
              // remove all constraints to guard against edge cases
              NSLayoutConstraint.deactivate(vc.view.animator().constraints)
              vc.view.removeFromSuperview()
            }
            self.tabsStackView
              .animator()
              .removeArrangedSubview(vc.view)
          }

          // present the added tabs
          tabViewControllersToAdd.forEach {
            self.addChild($0)
            $0.view.alphaValue = 0
            self.tabsStackView
              .animator()
              .addArrangedSubview($0.view)
            $0.view
              .animator()
              .alphaValue = 1
          }
          
          // update tab sizes
          self.updateTabSizes()
        
        },
      
      self.publisher(for: \.viewModel?.activeTab?.label)
        .sink { [unowned self] activeTabId in
          self.updateTabSizes()
        },
      
      self.publisher(for: \.viewModel?.activeTabId)
        .sink { [unowned self] activeTabId in
          // update active vc
          for case let tabViewController as TabViewController in self.children {
            tabViewController.isActive = tabViewController.tab.id == activeTabId
          }
          
          self.updateTabSizes()
        },
    ]
  }
  
  var viewSubscriptions: [Any] {
    [
      self.publisher(for: \.view.frame)
        .removeDuplicates()
        .sink { [unowned self] _ in
          self.updateTabSizes(animate: false)
        }
    ]
  }
  
  
  // MARK: misc
  
  func newTabViewController(tab: Tab) -> NSViewController {
    let tabViewController = TabViewController()
    tabViewController.tab = tab
    return tabViewController
  }
  
  func tabViewController(decendentView: NSView) -> TabViewController? {
    for case let tabViewController as TabViewController in children {
      if decendentView.isDescendant(of: tabViewController.view) {
        return tabViewController
      }
    }
    return nil
  }
  
  var activeTabViewController: TabViewController? {
    for case let tabViewController as TabViewController in children {
      if tabViewController.tab.id == viewModel?.activeTabId {
        return tabViewController
      }
    }
    return nil
  }
  
  var tabViewControllers: [TabViewController] {
    children.compactMap { $0 as? TabViewController }
  }
  
}


#Preview {
  let viewController =  TabCollectionViewController()
  viewController.viewModel = ToolbarViewModel.stub
  viewController.viewModel?.tabs.append(contentsOf: [
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
  ])
  return viewController
}


func constraint(view: NSView, id: String, priority: NSLayoutConstraint.Priority? = nil,`init`: () -> NSLayoutConstraint) -> NSLayoutConstraint {
  // IT1 naiive impl: remove constraints with same id and re-create.
  view.removeConstraints(view.constraints.filter { $0.identifier == id })
  let constraint = `init`()
  constraint.identifier = id
  if let priority = priority {
    constraint.priority = priority
  }
  return constraint
}

