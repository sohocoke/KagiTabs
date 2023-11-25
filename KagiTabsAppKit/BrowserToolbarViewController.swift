import AppKit



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
  }

}
