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
  
  @IBOutlet @objc dynamic weak var tabContainerView: NSScrollView!

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
//    // first update active tab width
//    activeTabViewController?.updateToIdealWidth()
//    
//    // determine the modes of the tabs based on cum. width <> container width
//    let tabCount = children.filter { $0 is TabViewController }.count
//    let activeTabWidth = activeTabViewController?.view.intrinsicContentSize.width ?? 0
//    let horizontalInsets = tabButtonsStackView.edgeInsets.left + tabButtonsStackView.edgeInsets.right
//    let totalInsets = horizontalInsets * CGFloat(tabCount)
//    let totalSpacing = tabButtonsStackView.spacing * CGFloat(tabCount - 1)
//    let remainingContainerWidth = tabContainerView.frame.width - activeTabWidth - totalInsets
//    
//    for case let inactiveTabViewController as TabViewController in children
//    where inactiveTabViewController.tab.id != viewModel?.activeTabId {
//      inactiveTabViewController.updateWidth(remainingContainerWidth: remainingContainerWidth, tabCount: tabCount - 1)
//    }
    
    
    // IT2 use constraints
    
    // update active tab width TODO
    
    
  }
  
  
  // MARK: kvo
  
  var viewModelSubscriptions: [Any] {
    [
      self.publisher(for: \.viewModel?.tabs)
        .scan(([], [])) { (priorClosureResult, current) -> ([Tab], [Tab]) in
          let (_, prior) = priorClosureResult
          return (prior, current ?? [])
        }
        .filter { $0 != $1 }
        .map { prior, current in
          let oldTabIds = prior.map { $0.id }
          let newTabIds = current.map { $0.id }
          
          let added = current.filter { !oldTabIds.contains($0.id) }
          let removed = prior.filter { !newTabIds.contains($0.id) }
          return (added, removed)
        }
        .sink { [unowned self] added, removed in
          // update removed
          for case let tabViewController as TabViewController in self.children {
            if removed.contains(where: { $0.id == tabViewController.tab.id}) {
//              tabViewController.view.removeFromSuperview()
              tabContainerView.documentView?.removeFromTiled(subview: tabViewController.view)
              tabViewController.removeFromParent()
            }
          }
          
          // update added
          var tabViews: [NSView] = []
          for tab in added {
            let tabViewController = self.newTabViewController(tab: tab)
            self.addChild(tabViewController)
            tabViews.append(tabViewController.view)
          }
          tabContainerView.documentView?.addTiled(subviews: tabViews)
          
          // update tab sizes
          self.updateTabSizes()
        },
      
      self.publisher(for: \.viewModel?.activeTabId)
        .sink { [unowned self] _ in
          self.updateTabSizes()
//          
//          // TODO remove active tab constraint from previous
//          
//          // TODO add active tab constraint to current
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
      self.publisher(for: \.tabContainerView.frame)
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
