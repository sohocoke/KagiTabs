//
//  TestButtonStylingViewController.swift
//  KagiTabsPreview
//
//  Created by ilo on 06/12/2023.
//

import Cocoa

class TestRectangleStylingViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.setDebugBorder(.red)
    
    self.view.translatesAutoresizingMaskIntoConstraints = false
    
    // IT2 a view with a shadow and a background layer that plays well with resize animations.
    let view = NSView()
    view.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(view)

    // width, to be animated later
    let widthC = view.widthAnchor.constraint(equalToConstant: 50)
    widthC.isActive = true
    
    // height and centre position
    view.heightAnchor.constraint(equalToConstant: 50).isActive = true
    view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    self.view.layoutSubtreeIfNeeded()

    view.setupBackgroundLayerAndShadow()

    view.setDebugBorder(.red)

    // we can see the background works well with animations.
    widthC.animator().constant = 500

  }
}

#Preview {
  TestRectangleStylingViewController()
}
