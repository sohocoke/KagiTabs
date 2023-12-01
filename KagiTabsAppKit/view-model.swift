import Foundation



class BrowserWindowViewModel: NSObject {
  
  @objc dynamic
  let toolbar: ToolbarViewModel
  
  init(toolbar: ToolbarViewModel) {
    self.toolbar = toolbar
  }
}


class ToolbarViewModel: NSObject {
  
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
  
  
  internal init(tabs: [Tab]) {
    self.tabs = tabs
    if let lastTab = tabs.last {
      self.activeTabId = lastTab.id
    }
  }
  
  
  @discardableResult
  func addNewTab() -> Tab {
    let tab = Tab(label: "Blank Tab")
    self.tabs.append(tab)
    return tab
  }
  
  func close(tab: Tab) {
    self.tabs.removeAll { $0.id == tab.id }
  }
  
  
  // MARK: derived properties
  
  var lastAddedTab: Tab? {
    tabs.last
  }
  
  @objc dynamic
  var activeTab: Tab? {
    tabs.last { $0.id == activeTabId }
  }
}


class Tab: NSObject, Identifiable {
  internal init(label: String = "New Tab", url: URL? = nil, faviconImageData: Data? = nil) {
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



// MARK: -

extension ToolbarViewModel {
  static var stub = ToolbarViewModel(tabs: [
    Tab(label: "Orion", url: URL(string: "https://kagi.com/orion")!),
    Tab(label: "Kagi", url: URL(string: "https://kagi.com")!),
    Tab(),
    Tab(label: "Apple", url: URL(string: "https://apple.com")!),
  ])
}
