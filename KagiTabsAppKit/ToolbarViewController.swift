import Cocoa


class ToolbarViewController: NSViewController {

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
  @IBOutlet @objc dynamic weak var tabContainerView: NSView!

  var observations: Any?
  

  // MARK: view lifecycle
  
  override func viewWillAppear() {
    super.viewWillAppear()
    self.observations = [
      viewModelObservations,
      viewObservations
    ]
  }
  
  override func viewWillDisappear() {
    self.observations = nil
    super.viewWillDisappear()
  }

  
  // MARK: tab actions
  
  @IBAction func addTab(_ sender: Any) {
    self.viewModel?.addNewTab()
  }

  @IBAction func closeTab(_ sender: NSView) {
    if let tabViewController = tabViewController(decendentView: sender) {
      self.viewModel?.close(tab: tabViewController.tab)
    }
  }
  
  @IBAction func activateTab(_ sender: NSView) {
    if let tabViewController = tabViewController(decendentView: sender) {
      self.viewModel?.activeTabId = tabViewController.tab.id
    }
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
  
  var viewModelObservations: Any? {
    [
      self.observe(\.viewModel?.tabs, options: [.initial, .old, .new]) { viewController, change in
        let oldTabIds = change.oldValue??.map { $0.id } ?? []
        let newTabIds = change.newValue??.map { $0.id } ?? []
        
        let added = Set(newTabIds).subtracting(oldTabIds)
        let removed = Set(oldTabIds).subtracting(newTabIds)
        
        // update removed
        for case let tabViewController as TabViewController in viewController.children {
          if removed.contains(tabViewController.tab.id) {
            viewController.tabButtonsStackView.removeArrangedSubview(tabViewController.view)
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
  
  var viewObservations: Any? {
    self.observe(\.tabContainerView.frame, options: [.old, .new]) { viewController, change in
      if change.newValue?.width != change.oldValue?.width {
        viewController.updateTabSizes()
      }
    }
  }
  
  
  // MARK: misc
  
  func newTabViewController(tab: Tab) -> NSViewController {
    let tabViewController = TabViewController(nibName: .init("TabView"), bundle: nil)
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


// MARK: - view model

class ToolbarViewModel: NSObject {
  internal init(tabs: [Tab]) {
    self.tabs = tabs
  }
  
  @objc dynamic
  var tabs: [Tab]
  
  @objc dynamic
  var activeTabId: Tab.ID?
  
  static var stub = ToolbarViewModel(tabs: [
    Tab(label: "asddklf"),
    Tab(label: "asddklf"),
    Tab(label: "asddklf"),
    Tab(label: "asddklf"),
  ])
  
  func addNewTab() {
    self.tabs.append(Tab(label: "new tab"))
  }
  
  func close(tab: Tab) {
    self.tabs.removeAll { $0.id == tab.id }
  }
}


class Tab: NSObject, Identifiable {
  internal init(label: String) {
    self.label = label
  }
  
  let id: UUID = UUID()
  
  @objc dynamic
  var label: String
  
}


// MARK: - preview

#Preview {
  let viewController = NSStoryboard.main?.instantiateController(withIdentifier: "ToolbarViewController") as! ToolbarViewController
  viewController.viewModel = ToolbarViewModel.stub
  return viewController
}
