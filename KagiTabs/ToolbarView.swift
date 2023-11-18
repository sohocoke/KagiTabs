//
//  ToolbarView.swift
//  KagiTabs
//
//  Created by ilo on 19/11/2023.
//

import SwiftUI

struct ToolbarView: View {
  let tabs: [Tab]
  var handler: Handler?
  
  var body: some View {
    HStack {
      
      Button("Back") {
        handler?.onBack()
      }
      
      AddressView()
      
      TabsView(tabs: Tab.stubs)
      
      Button("New") {
        handler?.onNewTab()
      }
    }
  }
  
  @Observable class Handler {
    internal init(onBack: @escaping () -> Void, onNewTab: @escaping () -> Void) {
      self.onBack = onBack
      self.onNewTab = onNewTab
    }
    
    let onBack: () -> Void
    let onNewTab: () -> Void
  }
}


#Preview {
  ToolbarView(tabs: Tab.stubs)
}


struct AddressView: View {
  @State var address = ""
  
  var body: some View {
    TextField("URL", text: $address)
      .onSubmit {
        // TODO
      }
  }
}


struct TabsView: View {
  let tabs: [Tab]
  
  var body: some View {
    HStack {
      ForEach(tabs) { tab in
        if tabs.firstIndex(of: tab) != 0 {
          Divider()
        }
        Button(tab.label) {
          // TODO
        }
      }
    }
      .fixedSize(horizontal: false, vertical: true)
  }
}


struct Tab: Identifiable, Hashable {
  let id = UUID()
  let label: String = "abc"
}

extension Tab {
  static var stubs = [
    Tab(), Tab(), Tab(),
  ]
}
