import Cocoa

class AddressBarToolbarItem: NSToolbarItem {
  override init(itemIdentifier: NSToolbarItem.Identifier) {
    super.init(itemIdentifier: itemIdentifier)
    
    let textField = NSTextField(string: "test string")
    textField.addConstraint(
      textField.widthAnchor.constraint(greaterThanOrEqualToConstant: 150)
    )
    
    self.view = textField
    
    self.label = "address"
  }
}

class TabCollectionToolbarItem: NSToolbarItem {
  init(itemIdentifier: NSToolbarItem.Identifier, view: NSView) {
    
    super.init(itemIdentifier: itemIdentifier)

    self.view = view
        
    self.label = "tabs"
    
  }
}
