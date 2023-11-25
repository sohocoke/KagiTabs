//
//  TabsTest2.swift
//  KagiTabsAppKit
//
//  Created by ilo on 24/11/2023.
//

import Cocoa

class TabCollectionTestViewController: NSViewController {

  var tabCollectionViewController: TabCollectionViewController!
  
  lazy var testScrollViewController = TestScrollViewController(nibName: nil, bundle: nil)

  @IBOutlet weak var tabCollectionContainerView: NSView!
  
  override func viewDidLoad() {
      super.viewDidLoad()

    tabCollectionViewController = TabCollectionViewController(nibName: nil, bundle: nil)
    tabCollectionViewController.viewModel = ToolbarViewModel.stub
    
    tabCollectionContainerView.addSubview(
      tabCollectionViewController.view
//      testScrollViewController.view
    )
    tabCollectionContainerView.setDebugBorder(.blue)
    tabCollectionViewController.view.setDebugBorder(.red)
  }
    
  @IBAction func addTab(_ sender: Any) {
    tabCollectionViewController.viewModel?.addNewTab()
  }
}


#Preview {
  NSStoryboard(
    name: "TabCollectionTest",
    bundle: nil
  ).instantiateInitialController() as! TabCollectionTestViewController
}


extension NSView {
  func setDebugBorder(_ colour: NSColor) {
    self.wantsLayer = true
    self.layer?.borderColor = colour.cgColor
    self.layer?.borderWidth = 2

  }
}
