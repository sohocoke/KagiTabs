//
//  ViewController.swift
//  KagiTabsPreview
//
//  Created by ilo on 22/11/2023.
//

import Cocoa

class ViewController: NSViewController {

  var testDynamicConstraintsViewController = TestDynamicConstraintsViewController()
  var scrollViewController = TestScrollViewController(nibName: nil, bundle: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()

//    // ** test dynamic constraints for equal widths
//    self.view = testDynamicConstraintsViewController.view
//    testDynamicConstraintsViewController.view.setDebugBorder(.blue)
    
    // ** test scrollable stack view that shrinks items before scrolling enabled
    self.addChild(scrollViewController)
    self.view.addSubview(scrollViewController.view)
    scrollViewController.view.frame = self.view.bounds
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }

}

