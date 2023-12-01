import Cocoa



class BrowserWindowController: NSWindowController {
  
  @objc dynamic
  var viewModel = BrowserWindowViewModel(toolbar: ToolbarViewModel.stub)
  
  /// set during toolbar delegate method invocation.
  var browserToolbarViewController: BrowserToolbarViewController?
  

  var subscriptions: Any?

  
  // MARK: window lifecycle
  
  override func windowDidLoad() {
    super.windowDidLoad()
    subscriptions = viewModelSubscriptions
  }
  
  
  // MARK: tab actions
  // note: we can't get the toolbar view controller to go on the responder chain when we present its view as a toolbar item.
  // we define the actions here so toolbar item validation and control action dispatches work with toolbar presentation.
  
  @IBAction func addTab(_ sender: Any) {
    self.viewModel.toolbar.addNewTab()
  }

  @IBAction func closeTab(_ sender: NSView) {
    if let tabViewController = browserToolbarViewController?.tabCollectionViewController?.tabViewController(decendentView: sender) {
      self.viewModel.toolbar.close(tab: tabViewController.tab)
    }
  }
  
  @IBAction func activateTab(_ sender: NSView) {
    if let tabViewController = browserToolbarViewController?.tabCollectionViewController?.tabViewController(decendentView: sender) {
      self.viewModel.toolbar.activeTabId = tabViewController.tab.id
    }
  }

  
  // MARK: browser content actions
    
  // first port of call when address entered.
  // looks like we need better mediation between the tabs and browser content.
  @IBAction func addressFieldSubmitted(_ sender: NSTextField) {
    guard let url = URL(string: sender.stringValue)
    else {
        print("invalid url!")
        return
      }

    let tab: Tab
    if let activeTab = viewModel.toolbar.activeTab {
      tab = activeTab
    } else {
      tab = viewModel.toolbar.addNewTab()
      viewModel.toolbar.activeTabId = tab.id
    }
    
    tab.url = url
  }
  
  
  var viewModelSubscriptions: Any {
    [
      self.publisher(for: \.viewModel.toolbar.activeTab)
        .sink { [unowned self] tab in
          guard let tab = tab
          else { return }
          
          let c = browserContentViewController(tab: tab)  // tidy!
          activate(browserContentViewController: c)
        },
      self.publisher(for: \.viewModel.toolbar.tabs)
        .scan(([], [])) { (priorClosureResult, current) -> ([Tab], [Tab]) in
          let (_, prior) = priorClosureResult
          return (prior, current)
        }
        .map { prior, current in
          let newTabIds = current.map { $0.id }
          
          let removed = prior.filter { !newTabIds.contains($0.id) }
          return removed
        }
        .sink { [unowned self] removedTabs in
          for removed in removedTabs {
            tearDownBrowser(tab: removed)
          }
        }
    ]
  }
  
  
  // MARK: managing browser content

  func browserContentViewController(tab: Tab) -> BrowserContentViewController {
    if let vc = contentViewController?.children.first(where: { ($0 as? BrowserContentViewController)?.tab?.id == tab.id }) {
      return vc as! BrowserContentViewController
    }
    
    guard let browserContentViewController = NSStoryboard(name: "BrowserContent", bundle: nil).instantiateInitialController() as? BrowserContentViewController
    else { fatalError() }

    browserContentViewController.tab = tab
    
    // keep ref as a child; ensure removal in teardown routine.
    contentViewController?.addChild(browserContentViewController)
    
    return browserContentViewController
  }
  
  func tearDownBrowser(tab: Tab) {
    for case let vc as BrowserContentViewController in contentViewController?.children ?? []
    where vc.tab?.id == tab.id {
      vc.tearDown()
    }
  }

  func activate(browserContentViewController: BrowserContentViewController) {
    // assuming no unrelated subviews!
    contentViewController?.view.subviews.forEach {
      $0.removeFromSuperview()
    }
    contentViewController?.view.addSubview(browserContentViewController.view)
    browserContentViewController.view.frame = contentViewController!.view.bounds
  }

}
