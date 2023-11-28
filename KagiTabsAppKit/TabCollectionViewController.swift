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
