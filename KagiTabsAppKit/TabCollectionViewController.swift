import Cocoa
import Combine



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
    let activeTabViewController = self.activeTabViewController
 
    // use width constraints and compression resistance
    if let activeView = activeTabViewController?.tabView {
      let inactiveViews = children.filter {
        $0 is TabViewController
        && $0.view != activeView
      }.map { $0.view }
      allowCompression(inactiveViews, except: activeView)
      
      updateToSameWidthConstraints(inactiveViews, superview: tabsStackView)
      
      // if sum(item.width) > scroll view width,
      let totalItemsWidth: CGFloat = tabViewControllers.reduce(.zero) { acc, e in
        acc + e.tabView.idealSize.width
      }
      if totalItemsWidth > tabsScrollView.frame.width {
        
        // if sum(item.minWidth) < scroll view width,
        let totalItemsMinWidth: CGFloat = tabViewControllers.reduce(.zero) { acc, e in
          acc + e.tabView.minSize.width
        }
        if totalItemsMinWidth < tabsScrollView.frame.width {
          // pin stack view width to scroll view width.
          let c = tabsStackView.widthAnchor.constraint(equalTo: tabsScrollView.widthAnchor)
          c.identifier = "tabsStackWidthPinnedToScrollViewFrame"
          c.isActive = true
          
        } else {
          // if sum(item.minWidth) > scroll view width,
          // need to scroll: unpin stack view width.
          tabsScrollView.constraints.filter {
            $0.identifier == "tabsStackWidthPinnedToScrollViewFrame"
          }.forEach {
            $0.isActive = false
          }
        }
        
      } else {
        // unpin any prior.
        tabsScrollView.constraints.filter {
          $0.identifier == "tabsStackWidthPinnedToScrollViewFrame"
        }.forEach {
          $0.isActive = false
        }
      }
      
      // outstanding issues:
      // when items compressed, width becomes ambiguous
      // - can result in active tab presentation being off
      // - consider adding explicit width constraints to avoid
      // when content becomes scrollable, items spring back to intrinsic size
      // - also consider adding constraints
    }
  }
  
  var tabViewControllers: [TabViewController] {
    children.compactMap { $0 as? TabViewController }
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
          // update removed
          for case let tabViewController as TabViewController in self.children {
            if removed.contains(where: { $0.id == tabViewController.tab.id}) {
//              self.tabsDocumentView.removeFromTiled(subview: tabViewController.view)
              self.tabsStackView.removeArrangedSubview(tabViewController.view)
              tabViewController.view.removeFromSuperview()
              tabViewController.removeFromParent()
            }
          }
          
          // update added
          for tab in added {
            let tabViewController = self.newTabViewController(tab: tab)
            self.addChild(tabViewController)
//            self.tabsDocumentView.addTiled(subview: tabViewController.view)
            self.tabsStackView.addArrangedSubview(tabViewController.view)
          }
          
          // update tab sizes
          self.updateTabSizes()
        },
      
      self.publisher(for: \.viewModel?.activeTabId)
        .sink { [unowned self] _ in
          self.updateTabSizes()
        },
      
      self.publisher(for: \.viewModel?.activeTabId)
        .sink { [unowned self] activeTabId in
          for case let tabViewController as TabViewController in self.children {
            tabViewController.isActive = tabViewController.tab.id == activeTabId
          }
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
