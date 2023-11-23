import Cocoa


class ToolbarViewController: NSViewController {

  @IBOutlet weak var tabButtonsStackView: NSStackView!
  @IBOutlet weak var tabContainerView: NSView!

  @objc dynamic
  var viewModel: ToolbarViewModel?
  
  var observations: Any?
  

  override func viewWillAppear() {
    super.viewWillAppear()
    
    self.observations = viewModelObservations
    
  }
  
  override func viewWillDisappear() {
    self.observations = nil
    
    super.viewWillDisappear()
  }

  
  
  @IBAction func addTab(_ sender: Any) {
    self.viewModel?.addNewTab()
  }

  @IBAction func closeTab(_ sender: NSView) {
    if let tabViewController = children.first(where: {
      sender.isDescendant(of: $0.view)
    }),
    let tabViewController = tabViewController as? TabViewController {
      self.viewModel?.close(tab: tabViewController.tab)
    }
  }
  

  func updateTabSizes() {
    // determine the modes of the tabs based on cum. width <> container width
    let tabCount = self.children.filter { $0 is TabViewController }.count
    let containerWidth = tabContainerView.frame.width
    for child in self.children {
      if let tabViewController = child as? TabViewController {
        tabViewController.updateWidth(remainingContainerWidth: containerWidth, tabCount: tabCount)
      }
    }
  }
  
  
  var viewModelObservations: Any? {
    [
      self.observe(\.viewModel?.tabs, options: [.initial, .old, .new]) { [self] _, change in
        let oldTabIds = change.oldValue??.map { $0.id } ?? []
        let newTabIds = change.newValue??.map { $0.id } ?? []
        
        let added = Set(newTabIds).subtracting(oldTabIds)
        let removed = Set(oldTabIds).subtracting(newTabIds)
        
        // update removed
        for tabViewController in self.children {
          if let tabViewController = tabViewController as? TabViewController,
             removed.contains(tabViewController.tab.id) {
            tabButtonsStackView.removeArrangedSubview(tabViewController.view)
            tabViewController.view.removeFromSuperview()
            tabViewController.removeFromParent()
          }
        }
        
        // update added
        for tabId in added {
          if let tab = change.newValue??.first(where: { $0.id == tabId }) {
            let tabViewController = newTabViewController(tab: tab)
            self.addChild(tabViewController)
            tabButtonsStackView.addArrangedSubview(tabViewController.view)
          }
        }
        
        // update tab sizes
        updateTabSizes()
      },
      self.observe(\.viewModel?.activeTabId, options: [.initial, .new]) { [self] _, change in
        updateTabSizes()
      }
    ]
  }
  
  func newTabViewController(tab: Tab) -> NSViewController {
    let tabViewController = TabViewController(nibName: .init("TabView"), bundle: nil)
    tabViewController.tab = tab
    return tabViewController
  }
}


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
  var label: String
  
}



#Preview {
  let viewController = NSStoryboard.main?.instantiateController(withIdentifier: "ToolbarViewController") as! ToolbarViewController
  viewController.viewModel = ToolbarViewModel.stub
  return viewController
}
