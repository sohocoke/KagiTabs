import Cocoa

class TestTabCollectionViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
      
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if let tcvc = segue.destinationController as? TabCollectionViewController {
      tcvc.viewModel = ToolbarViewModel.stub
    }
  }
}
