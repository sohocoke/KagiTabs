//
//  ToolbarView.swift
//  KagiTabs
//
//  Created by ilo on 19/11/2023.
//

import SwiftUI

struct ToolbarView: View {
  @EnvironmentObject var viewModel: ViewModel
  var handler: Handler
  
  var body: some View {
    HStack {
      
      Button("Back") {
        handler.onBack()
      }
      
      AddressView()
      
      TabsView(tabs: viewModel.tabs)
      
      Button("New") {
        handler.onNewTab()
      }
    }
  }
  
  class ViewModel: ObservableObject {
    @Published var tabs: [Tab] = Tab.stubs
    
    func addTab() {
      tabs.append(Tab())
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
  let tabs: [Tab]
  
  @State var activeTabId: Tab.ID?
  
  var body: some View {
    HStack {
      ForEach(tabs) { tab in
        if tabs.firstIndex(of: tab) != 0 {
          Divider()
        }

        TabView(
          tab: tab,
          isActive: activeTabId == tab.id,
          onSelect: { tab in
            self.activeTabId = tab.id
          }
        )
      }
    }
      .fixedSize(horizontal: false, vertical: true)
  }
}

struct TabView: View {
  let tab: Tab
  let isActive: Bool
  let onSelect: (Tab) -> Void
  
  @State var isHoveredOnFavicon = false
  
  var body: some View {
    Button {
      onSelect(tab)
    } label: {
      HStack {
        Image(systemName: "rectangle")
          .overlay(
            ZStack {
              if isHoveredOnFavicon {
                Button("x") {
                  // TODO
                }
                // TODO position
              }
            }
          )
          .onHover { isHovered in
            self.isHoveredOnFavicon = isHovered
          }
        Text(tab.label)
      }
    }
    .buttonStyle(.plain)
    .background(
      ZStack {
        if isActive {
          Rectangle()
        }
      }
    )
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


#Preview {
  PreviewWrapper()
}


struct PreviewWrapper: View {
  @State var viewModel = ToolbarView.ViewModel()
  
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
