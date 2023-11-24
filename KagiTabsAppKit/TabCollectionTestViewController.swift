//
//  TabsTest2.swift
//  KagiTabsAppKit
//
//  Created by ilo on 24/11/2023.
//

import Cocoa

class TabCollectionTestViewController: NSViewController {

  var contentViewController: TabCollectionViewController!
  
  @IBOutlet weak var tabCollectionContainerView: NSView!
  
  override func viewDidLoad() {
      super.viewDidLoad()

    contentViewController = TabCollectionViewController(nibName: nil, bundle: nil)
    contentViewController.viewModel = ToolbarViewModel.stub
    
    tabCollectionContainerView.addSubview(
      contentViewController.view
    )
  }
    
  @IBAction func addTab(_ sender: Any) {
    contentViewController.viewModel?.addNewTab()
  }
}


#Preview {
  NSStoryboard(
    name: "TabCollectionTest",
    bundle: nil
  ).instantiateInitialController() as! TabCollectionTestViewController
}
