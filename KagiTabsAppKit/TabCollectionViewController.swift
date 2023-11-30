import Cocoa
import Combine


/// outstanding animations:
/// - frame change on tab activation
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
  
  func updateTabSizes() {
    guard let activeView = activeTabViewController?.tabView
    else { return }
    
    let inactiveViews = tabViewControllers.filter {
      $0.view != activeView
    }.map { $0.tabView }
    

    // ** use width constraints and compression resistance.
    
    allowCompression(inactiveViews, except: activeView)
    
    updateToEqualWidthConstraints(inactiveViews, superview: tabsStackView)
    
    // set active view width >= 1st inactive,
    // so it doesn't display less prominently if narrow.
    if let firstInactive = inactiveViews.first {
      let c = activeView.widthAnchor.constraint(greaterThanOrEqualTo: firstInactive.widthAnchor)
      c.identifier = "sameWidths" // reusing this constraint id.
      c.isActive = true
    }
    
    // ** pin stack view and item wim width for certain conditions for ( scroll view width, sum(item.width), sum(item.minWidth) ),
    // to get scrolling + compression working.

    let totalItemsWidth: CGFloat = tabViewControllers.reduce(.zero) { acc, e in
      acc + 
      e.tabView.idealSize.width
    }

    let totalItemsMinWidth: CGFloat = tabViewControllers.reduce(.zero) { acc, e in
      let width = e.isActive
        ? e.tabView.idealSize.width
        : e.tabView.minSize.width
      return acc + width
    }
    
    // clear the first tab min size constraint, then add when necessary below.
    tabViewControllers.forEach {
      $0.tabView.constraints.filter { $0.identifier == "firstTabToMinSize" }
        .forEach { $0.isActive = false }
    }
    
    // if sum(item.width) exceeds scroll view width,
    if tabsScrollView.frame.width > 0
        && totalItemsWidth > 0
        && totalItemsWidth > tabsScrollView.frame.width {
      
      // if sum(item.minWidth) within scroll view width,
      if totalItemsMinWidth < tabsScrollView.frame.width {

        // switch off scrolling so items can conpress.
        self.isScrollable = false

      } else {
        // sum(item.minWidth) exceeds scroll view width.

        // turn on scrolling and constrain first inactive tab to minsize.
        self.isScrollable = true
        if let v = inactiveViews.first {
          let c = v.animator().widthAnchor.constraint(equalToConstant: v.minSize.width)
          c.identifier = "firstTabToMinSize"
          c.isActive = true
        }
      }
      
    } else {
      // enable scrolling which would be a no-op for these widths.
      
      self.isScrollable = true
    }
  }
  
  var isScrollable: Bool = false {
    didSet {
      if isScrollable {
        // unpin the stackview from the scrollview.
        tabsScrollView.constraints.filter {
          $0.identifier == "tabsStackWidthPinnedToScrollViewFrame"
        }.forEach {
          $0.isActive = false
        }
      }
      else {
        // pin the stackview from the scrollview so items can compress
        // without pushing out scrollable content.
        let c = tabsStackView.widthAnchor.constraint(equalTo: tabsScrollView.widthAnchor)
        c.identifier = "tabsStackWidthPinnedToScrollViewFrame"
        c.isActive = true
      }
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
      
      self.publisher(for: \.viewModel?.activeTabId)
        .sink { [unowned self] activeTabId in
          // update active vc
          for case let tabViewController as TabViewController in self.children {
            tabViewController.isActive = tabViewController.tab.id == activeTabId
          }
          
          // update tabs accordingly
//          NSAnimationContext.runAnimationGroup { context in
//            context.allowsImplicitAnimation = true
            self.updateTabSizes()
//          }
        },
    ]
  }
  
  var viewSubscriptions: [Any] {
    [
      self.publisher(for: \.tabsScrollView.frame)
        .removeDuplicates()
        .sink { [unowned self] _ in
          self.updateTabSizes()
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
