//
//  ToolbarView.swift
//  KagiTabs
//
//  Created by ilo on 19/11/2023.
//

import SwiftUI

struct ToolbarView: View {
  
  var handler: Handler
  
  var body: some View {
    HStack {
      
      Button("Back") {
        handler.onBack()
      }
      
      AddressView()
      
      TabsView()
      
      Button("New") {
        handler.onNewTab()
      }
    }
  }
  
  
  class Handler {
    internal init(onBack: @escaping () -> Void, onNewTab: @escaping () -> Void) {
      self.onBack = onBack
      self.onNewTab = onNewTab
    }
    
    let onBack: () -> Void
    let onNewTab: () -> Void
  }

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
  @EnvironmentObject var viewModel: ViewModel

  @State var activeTabId: Tab.ID?
  
  var body: some View {
    HStack {
      ForEach(viewModel.tabs) { tab in
        if viewModel.tabs.first != tab {
          Divider()
        }

        TabView(
          tab: tab,
          isActive: activeTabId == tab.id,
          onSelect: { tab in
            self.activeTabId = tab.id
          },
          onClose: { tab in
            viewModel.close(tab: tab)
          }
        )
      }
    }
      .fixedSize(horizontal: false, vertical: true)
  }
  
  class ViewModel: ObservableObject {
    @Published var tabs: [Tab] = Tab.stubs
    
    func addTab() {
      tabs.append(Tab())
    }
    
    func close(tab: Tab) {
      tabs.removeAll { $0.id == tab.id }
    }
  }

}

// TODO when active, should lay out 'prominently' vis-a-vis other tabs.
struct TabView: View {
  let tab: Tab
  let isActive: Bool
  
  let onSelect: (Tab) -> Void
  let onClose: (Tab) -> Void
  
  @State var isHovered = false
  @State var isHoveredOnFavicon = false
  
  var body: some View {
    Button {
      onSelect(tab)
    } label: {
      HStack {
        tab.faviconImage
        .overlay(
          ZStack {
            if isHoveredOnFavicon {
              CloseTabButton {
                onClose(tab)
              }
            }
          }
        )
        .onHover { self.isHoveredOnFavicon = $0 }
        
        Text(tab.label)
      }
    }
    .buttonStyle(.plain)
    .background(
      TabBackgroundView(isActive: isActive, isHovered: isHovered)
    )
    
    .onHover { self.isHovered = $0 }
  }
}

struct TabBackgroundView: View {
  let isActive: Bool
  let isHovered: Bool
  
  var body: some View {
    ZStack {
      if isActive {
        Color.clear
          .border(.blue)
      } else if isHovered {
        Color.clear
          .border(.red)
      } else {
        Color.clear
      }
    }
  }
}

struct CloseTabButton: View {
  let action: () -> Void
  
  var body: some View {
    Button("x", action: action)  // STUB
  }
}


// MARK: -

struct Tab: Identifiable, Hashable {
  let id = UUID()
  let label: String = "abc"
  
  var faviconImage: Image {
    Image(systemName: "rectangle")
  }
}

extension Tab {
  static var stubs = [
    Tab(), Tab(), Tab(),
  ]
}


// MARK: -

#Preview {
  PreviewWrapper()
}


struct PreviewWrapper: View {
  @State var viewModel = TabsView.ViewModel()
  
  var body: some View {
    ToolbarView(
      handler: ToolbarView.Handler(
        onBack: {},
        onNewTab: {
          viewModel.addTab()
        }
      )
    )
    .environmentObject(viewModel)
  }
}
