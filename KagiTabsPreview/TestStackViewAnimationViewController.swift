//
//  TestStackViewAnimationViewController.swift
//  KagiTabsPreview
import Cocoa



// just basic animations to give the user enough cues for their actions.
// fancier animations will likely run into CA oddities specific to AppKit, so defer for now.
class TestStackViewAnimationViewController: NSViewController {

  @IBOutlet var stackView: NSStackView!
  @IBOutlet var testView: NSView!
  
  @IBAction func addItem(_ sender: Any) {
    let button = NSButton(title: "Remove", target: self, action: #selector(removeItem(_:)))
    
    button.isHidden = true
    
    NSAnimationContext.runAnimationGroup { context in
      context.allowsImplicitAnimation = true
      
      stackView.animator().addArrangedSubview(button)
    } completionHandler: {
      button.animator().isHidden = false
    }
    
  }
  
  @IBAction func removeItem(_ sender: NSView) {
    stackView.animator().removeArrangedSubview(sender)
    sender.animator().removeFromSuperview()
  }
}
