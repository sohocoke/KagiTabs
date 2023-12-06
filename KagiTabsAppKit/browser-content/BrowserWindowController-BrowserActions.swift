import AppKit


extension BrowserWindowController {
  
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
