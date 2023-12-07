import Cocoa
import Combine



// use some constants for width to simplify the logic,
// can elaborate later.
let activeTabMinWidth: CGFloat = 140
let activeTabMaxWidth: CGFloat = 300
let inactiveTabMinWidth: CGFloat = 100
let inactiveTabMaxWidth: CGFloat = 120


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
    
  
  // MARK: view lifecycle
  
    
  override func viewDidLoad() {
    super.viewDidLoad()
  
    // clear placeholder views from stack view.
    tabsStackView.arrangedSubviews.forEach {
      assert(!children.map { $0.view }.contains($0))
      tabsStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    
    self.subscriptions =
      viewModelSubscriptions
      + viewSubscriptions
    
//    self.view.setDebugBorder(.red)
  }
    
  
  // MARK: tab sizing
  
  func updateTabSizes(animate: Bool = true) {
    guard let activeView = activeTabViewController?.tabView
    else { return }
    
    let inactiveViews = tabViewControllers.compactMap { $0.view != activeView ? $0.tabView : nil }
    
    guard inactiveViews.count > 0
    else { return }
    
    // ** use width constraints and compression resistance.
    
    allowCompression(inactiveViews, except: activeView)
    
    // obtain / compute important lengths for constraint setup.
    
    let insets = tabsStackView.edgeInsets.left + tabsStackView.edgeInsets.right
    let availableWidth = view.frame.width - insets
    
    let activeItemWidth = min(
      max(
        activeView.idealSize.width,
        activeTabMinWidth,  // avoid tiny active tabs.
        inactiveTabMaxWidth  // at least as big as the inactive tabs.
      ),
      activeTabMaxWidth  // cap it at maxWidth
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
    // disallow fractional values
    var inactiveTabComputedWidth =  CGFloat( Int(availableInactiveWidth) / inactiveViews.count )
    
    inactiveTabComputedWidth = max(inactiveTabComputedWidth, inactiveTabSquishLowLimit)  // floor it at inactiveTabSquishLowLimit
    
    // sometimes we have plenty of space, letting us avoid capping any widths.
    let totalIdealWidth = activeItemWidth + inactiveViews.reduce(.zero) { acc, e in
      let widthWanted = min(
        max(
          e.idealSize.width,
          inactiveTabMinWidth  // avoid tiny inactive tabs
        ),
        inactiveTabMaxWidth  // cap at max width
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
      let activeWidthC = constraint(view: view, id: "activeWidth") {
        view.widthAnchor.constraint(equalToConstant: activeItemWidth)
      }
      
      // secure minimal widths for inactive tabs except in .needScroll, to avoid tiny tabs.
      let inactiveMinWidthC = constraint(
        view: view,
        id: "inactiveMinWidth",
        // allow compression unless in .noSquish
        priority: layoutCase == .noSquish ? .required : .defaultLow - 1
      ) {
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: inactiveTabMinWidth)
      }
      
      // limit max width for inactive tabs.
      let inactiveMaxWidthC = constraint(view: view, id: "inactiveMaxWidthC") {
        view.widthAnchor.constraint(lessThanOrEqualToConstant: inactiveTabMaxWidth)
      }
        
      // on .needSquish, set inactive tab widths to computed.
      let inactiveWidthC = constraint(view: view, id: "inactiveWidth", priority: .defaultHigh) {
        view.widthAnchor.constraint(equalToConstant: inactiveTabComputedWidth)
      }
        
      // on .needScroll, constrain inactive tab width to minimal width,
      // since scrolling requires minimal inactive tabs.
      let maxSquishWidthC = constraint(view: view, id: "maxSquishWidth") {
        view.widthAnchor.constraint(equalToConstant: inactiveTabSquishLowLimit)
      }
      
      switch (isActive, layoutCase) {
      case (true, _):
        NSLayoutConstraint.activate([activeWidthC])
        
      // rest is for inactive tab cases.
      case (_, .noSquish):
        NSLayoutConstraint.activate([
          inactiveMinWidthC,
          inactiveMaxWidthC,
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
      
    if animate {
      NSAnimationContext.runAnimationGroup { context in
        context.allowsImplicitAnimation = true
        
        view.animator().layoutSubtreeIfNeeded()
      }
    }
  }
    
  
  // MARK: kvo
  
  var viewModelSubscriptions: [Any] {
    [
      self.publisher(for: \.viewModel?.tabs, options: [.initial, .new])
        .prepend([])
        .map { [unowned self] tabs in
          let tabs = tabs ?? []
          let prior: [Tab] = self.children.compactMap {
            let vc = $0 as? TabViewController
            assert(vc == nil || vc!.view.superview != nil)
            
            return vc?.tab
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

            // adjusting alpha in the tab vc's didAppear or willAppear results in bad frame animation origin.
            // so prep it here.
            $0.view.alphaValue = 0
            
            self.tabsStackView
              .animator()
              .addArrangedSubview($0.view)
            $0.view.animator().alphaValue = 1
          }
          
          // update tab sizes
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
      
      // update sizes if active tab label changes.
      self.publisher(for: \.viewModel?.activeTab?.label)
        .sink { [unowned self] _ in
          // sadly, without an async dispatch, the model change is not applied to the view
          // for our size update to pick it up.
          // avoid convoluted kvo signalling from the label button to a neat keypath (e.g. \.activeTabController?. ...)
          // by doing an async dispatch.
          // a bit hacky but good enough for the simple use case.
          DispatchQueue.main.async {
            self.updateTabSizes()
          }
        },
      
      // update separators when tabset or active tab changes.
      self.publisher(for: \.viewModel?.tabs)
        .combineLatest(self.publisher(for: \.viewModel?.activeTabId).prepend(nil))
        .receive(on: DispatchQueue.main)
        .sink { [weak self] tabs, activeTabId in
        
          // update separators
          guard let tabViewControllers = self?.tabViewControllers
          else { return }
          
          if let activeVc = tabViewControllers.first(where: { $0.isActive }) {
            let vcsForNoSeparators = [
              tabViewControllers.previous(ofItem: activeVc),
              activeVc,
              tabViewControllers.last
            ].compactMap { $0 }
            
            tabViewControllers.forEach {
              $0.separator.isHidden = vcsForNoSeparators.contains($0)
            }
          }
        }
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


extension Array where Element: Equatable {
  func previous(ofItem item: Element) -> Element? {
    guard let i = firstIndex(of: item) else { return nil }
    guard i > 0 && self.count > 1 else {
      return nil
    }
    return self[i-1]
  }
}
