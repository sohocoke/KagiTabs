import Foundation



// MARK: - view model

class ToolbarViewModel: NSObject {
  internal init(tabs: [Tab]) {
    self.tabs = tabs
  }
  
  @objc dynamic
  var tabs: [Tab]
  
  @objc dynamic
  var activeTabId: Tab.ID?
  
  static var stub = ToolbarViewModel(tabs: [
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
    Tab(label: "test \(Date())"),
//    Tab(label: "test \(Date())"),
//    Tab(label: "test \(Date())"),
//    Tab(label: "test \(Date())"),
//    Tab(label: "test \(Date())"),
//    Tab(label: "test \(Date())"),
//    Tab(label: "test \(Date())"),
//    Tab(label: "test \(Date())"),
//    Tab(label: "test \(Date())"),
  ])
  
  func addNewTab() {
    self.tabs.append(Tab(label: "new tab"))
  }
  
  func close(tab: Tab) {
    self.tabs.removeAll { $0.id == tab.id }
  }
}


class Tab: NSObject, Identifiable {
  internal init(label: String) {
    self.label = label
  }
  
  let id: UUID = UUID()
  
  @objc dynamic
  var label: String
  
}
