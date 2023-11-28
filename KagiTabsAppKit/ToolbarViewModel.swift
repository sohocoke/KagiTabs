import Foundation



// MARK: - view model

class ToolbarViewModel: NSObject {
  internal init(tabs: [Tab]) {
    self.tabs = tabs
    if let lastTab = tabs.last {
      self.activeTabId = lastTab.id
    }
  }
  
  @objc dynamic
  var tabs: [Tab] {
    didSet {
      // when active tab closed, select the last tab.
      let currentIds = tabs.map { $0.id }
      let removed = oldValue.filter { !currentIds.contains($0.id) }
      if removed.contains(where: { $0.id == activeTabId }) {
        let lastTab = tabs.last
        self.activeTabId = lastTab?.id
      }
    }
  }
  
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
