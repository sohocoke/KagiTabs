import AppKit



// NOTE: in xib, we have a very tall fixed height, to ease testing inside the toolbar,
// pending optimisation.
class BrowserToolbarViewController: NSViewController {
  
  var tabCollectionViewController: TabCollectionViewController? {
    didSet {
      tabCollectionViewController?.viewModel = viewModel
    }
  }
  
  var viewModel: ToolbarViewModel? {
    didSet {
      tabCollectionViewController?.viewModel = viewModel
    }
  }
  

  // MARK: storyboard lifecycle
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let tabCollectionViewController = segue.destinationController as? TabCollectionViewController {
      self.tabCollectionViewController = tabCollectionViewController
    }
    
//    self.view.setDebugBorder(.red)  // DEBUG
  }

  // doesn't work because not in responder chain. :|
  @IBAction func addressFieldSubmitted(_ sender: NSTextField) {

  }
}
