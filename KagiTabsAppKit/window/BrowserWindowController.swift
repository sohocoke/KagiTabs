import Cocoa



class BrowserWindowController: NSWindowController {
  
  @objc dynamic
  var viewModel = BrowserWindowViewModel(
    toolbar: ToolbarViewModel(tabs: [
      Tab(label: "Welcome!", url: URL(string: "https://kagi.com/orion")!)
    ])
  )
  
  /// set during toolbar delegate method invocation.
  var browserToolbarViewController: BrowserToolbarViewController?
  

  var subscriptions: Any?

  
  // MARK: window lifecycle
  
  override func windowDidLoad() {
    super.windowDidLoad()
    subscriptions = viewModelSubscriptions
  }
  
  
  // MARK: wiring
  
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
  
}
