//
//  ViewController.swift
//  KagiTabsPreview
//
//  Created by ilo on 22/11/2023.
//

import Cocoa

class ViewController: NSViewController {

  var testDynamicConstraintsViewController = TestDynamicConstraintsViewController()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
//    self.view.addSubview(testDynamicConstraintsViewController.view)
//    testDynamicConstraintsViewController.view.frame = self.view.bounds
    self.view = testDynamicConstraintsViewController.view
//    testDynamicConstraintsViewController.view.setDebugBorder(.blue)
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }


}

