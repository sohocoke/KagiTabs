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

  // a 0-width constraint set up to position the address field correctly when no tabs.
  @IBOutlet weak var tabCollectionWidthWhenTabsHidden: NSLayoutConstraint?
  // limit the width of address field when tabs visible.
  @IBOutlet weak var addressFieldWidthWhenTabsVisible: NSLayoutConstraint?
  
  @objc dynamic
  var isTabsVisible: Bool = false {
    didSet {
      tabCollectionViewController?.view.isHidden = !isTabsVisible
      
      // avoid weird frame animation when address field is focused / text selected,
      // by juggling first responder when condition is met.
      //
      // due to time pressure, we choose not to re-organise the storyboard view controllers
      // in order to simply expose a ref to the text field.
      // this should be done differently in production-quality code.
      
      var firstResponderTextField: NSView?
      if let firstResponderView = view.window?.firstResponder as? NSView,
        // obtain the actual text field that we must make first responder, not the appkit field editor.
         let textField = firstResponderView.superview?.superview as? NSTextField,
         textField.isDescendant(of: view) {
        // a text field is first responder; keep hold of it, resign first responder,
        // then re-instate first responder status after animation.
        firstResponderTextField = textField
        
        view.window?.makeFirstResponder(nil)
      }
      
      NSAnimationContext.runAnimationGroup { context in
        context.allowsImplicitAnimation = true
        
        // zero-out the tabs width when not visible.
        tabCollectionWidthWhenTabsHidden?.animator().priority = isTabsVisible ? .defaultLow - 100 : .required
        // resize the address bar.
        addressFieldWidthWhenTabsVisible?.animator().priority = isTabsVisible ? .required : .defaultLow - 100
        
        self.view.animator().layoutSubtreeIfNeeded()
      } completionHandler: { [weak self] in
        if let textField = firstResponderTextField {
          self?.view.window?.makeFirstResponder(textField)
        }
      }
    }
  }

  
  var subscriptions: Any?
  
  
  // MARK: view lifecycle
  
  override func viewDidAppear() {
    super.viewDidAppear()

    self.subscriptions = viewModelSubscriptions
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
}
