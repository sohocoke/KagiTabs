import AppKit



class BrowserToolbarViewController: NSViewController {
  
  /// the toolbar data to render.
  @objc dynamic
  var viewModel: ToolbarViewModel? {
    didSet {
      tabCollectionViewController?.viewModel = viewModel
    }
  }

  /// manages all tab behaviour.
  var tabCollectionViewController: TabCollectionViewController? {
    didSet {
      tabCollectionViewController?.viewModel = viewModel
    }
  }
  
  /// constraint defined in xib that sizes the address field appropriately based on tabs visibility.
  @IBOutlet var addressFieldWidthWhenTabsShown: NSLayoutConstraint?


  @objc dynamic
  var isTabsVisible: Bool = false {
    didSet {
      NSAnimationContext.runAnimationGroup { context in
        self.addressFieldWidthWhenTabsShown?.isActive = isTabsVisible
        tabsContainerView?.animator().isHidden = !isTabsVisible
        
        self.view.layoutSubtreeIfNeeded()
      }
    }
  }

  
  var subscriptions: Any?
  
  
  // MARK: view lifecycle
  
  override func viewDidAppear() {
    super.viewWillAppear()
    
    self.subscriptions = viewModelSubscriptions
    self.isTabsVisible = viewModel?.tabs.count ?? 0 > 1
  }
  
  
  // MARK: storyboard lifecycle
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let tabCollectionViewController = segue.destinationController as? TabCollectionViewController {
      self.tabCollectionViewController = tabCollectionViewController
    }
    
//    self.view.setDebugBorder(.red)  // DEBUG
  }

  
  // MARK: misc
  
  // doesn't work because not in responder chain. :|
  // defined in window controller for now, until a better toolbar delegate is defined and wired up.
  @IBAction func addressFieldSubmitted(_ sender: NSTextField) {

  }
  
  var viewModelSubscriptions: Any {
    [
      self.publisher(for: \.viewModel?.tabs, options: [.initial, .new])
        .map { tabs in
          let shouldShowTabs = (tabs?.count ?? 0) > 1
          return shouldShowTabs
        }
        .assign(to: \.isTabsVisible, on: self)
    ]
  }
  

  // temp-outlet
  var tabsContainerView: NSView? {
    self.tabCollectionViewController?.view.superview
  }
}
