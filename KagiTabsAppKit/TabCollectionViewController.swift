import Cocoa



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
  
  @IBOutlet weak var tabButtonsStackView: NSStackView!
  @IBOutlet @objc dynamic weak var tabContainerView: NSScrollView!

  var observations: [NSKeyValueObservation] = []
  
  
  // MARK: initialisers

  required init?(coder: NSCoder) {
    super.init(nibName: nil, bundle: nil)
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  
  // MARK: view lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.observations =
      viewModelObservations
      + viewObservations
  }
  
  
  deinit {
    for o in observations {
      o.invalidate()
    }
    observations = []
  }
  
  
  // MARK: tab sizing
  
  func updateTabSizes() {
    // first update active tab width
    activeTabViewController?.updateToIdealWidth()
    
    // determine the modes of the tabs based on cum. width <> container width
    let tabCount = children.filter { $0 is TabViewController }.count
    let activeTabWidth = activeTabViewController?.view.intrinsicContentSize.width ?? 0
    let remainingContainerWidth = tabContainerView.frame.width - activeTabWidth
    
    for case let inactiveTabViewController as TabViewController in children
    where inactiveTabViewController.tab.id != viewModel?.activeTabId {
      inactiveTabViewController.updateWidth(remainingContainerWidth: remainingContainerWidth, tabCount: tabCount - 1)
    }
  }
  
  
  // MARK: kvo
  
  var viewModelObservations: [NSKeyValueObservation] {
    [
      self.observe(\.viewModel?.tabs, options: [.initial, .old, .new]) { viewController, change in
        guard change.oldValue != change.newValue else { return }
        let oldTabIds = change.oldValue??.map { $0.id } ?? []
        let newTabIds = change.newValue??.map { $0.id } ?? []
        
        let added = Set(newTabIds).subtracting(oldTabIds)
        let removed = Set(oldTabIds).subtracting(newTabIds)
        
        // update removed
        for case let tabViewController as TabViewController in viewController.children {
          if removed.contains(tabViewController.tab.id) {
            tabViewController.view.removeFromSuperview()
            tabViewController.removeFromParent()
          }
        }
        
        // update added
        for tabId in added {
          if let tab = change.newValue??.first(where: { $0.id == tabId }) {
            let tabViewController = viewController.newTabViewController(tab: tab)
            viewController.addChild(tabViewController)
            viewController.tabButtonsStackView.addArrangedSubview(tabViewController.view)
          }
        }
        
        // update tab sizes
        viewController.updateTabSizes()
      },
      self.observe(\.viewModel?.activeTabId, options: [.initial, .new]) { viewController, change in
        viewController.updateTabSizes()
      }
    ]
  }
  
  var viewObservations: [NSKeyValueObservation] {
    [
      self.observe(\.tabContainerView.frame, options: [.old, .new]) { viewController, change in
        if change.newValue?.width != change.oldValue?.width {
          viewController.updateTabSizes()
        }
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
