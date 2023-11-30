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
  var activeTabId: Tab.ID? {
    willSet {
      willChangeValue(forKey: #keyPath(ToolbarViewModel.activeTab))
    }
    didSet {
      didChangeValue(forKey: #keyPath(ToolbarViewModel.activeTab))
    }
  }
  
  static var stub = ToolbarViewModel(tabs: [
    Tab(label: "test \(Date())", url: URL(string: "https://example.com")!),
    Tab(label: "test \(Date())", url: URL(string: "https://kagi.com")!),
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
  
  @discardableResult
  func addNewTab() -> Tab {
    let tab = Tab(label: "Blank Tab")
    self.tabs.append(tab)
    return tab
  }
  
  func close(tab: Tab) {
    self.tabs.removeAll { $0.id == tab.id }
  }
  
  // MARK: -
  
  var lastAddedTab: Tab? {
    tabs.last
  }
  
  @objc dynamic
  var activeTab: Tab? {
    tabs.last { $0.id == activeTabId }
  }
}


class Tab: NSObject, Identifiable {
  internal init(label: String, url: URL? = nil, faviconImageData: Data? = nil) {
    self.label = label
    self.url = url
    self.faviconImageData = faviconImageData
  }
  
  let id: UUID = UUID()
  
  @objc dynamic
  var label: String
  
  @objc dynamic
  var url: URL?
  
  @objc dynamic
  var faviconImageData: Data?
}

