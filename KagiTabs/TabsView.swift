import SwiftUI


struct TabsView: View {
  @EnvironmentObject var viewModel: ViewModel
  
  var body: some View {
    HStack {
      ForEach(viewModel.tabs) { tab in
        if viewModel.tabs.first != tab {
          Divider()
        }

        TabView(
          tab: tab,
          isActive: viewModel.activeTabId == tab.id,
          onSelect: { tab in
            viewModel.activeTabId = tab.id
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
    @Published var activeTabId: Tab.ID?
    
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
        
        if isActive {
          Text(tab.label)
            .fixedSize()
        } else {
          Text(tab.label)
            .lineLimit(1)
        }
        // REFINE minimum size so inactive tab can still be chosen
        // REFINE ensure no overflow
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
  var label: String = "abc"
  
  var faviconImage: Image {
    Image(systemName: "rectangle")  // STUB
  }
}

extension Tab {
  static var stubs = [
    Tab(),
    Tab(),
    Tab(label: "website with some really long title"),
    Tab(label: "another website with some really long title"),
  ]
}

#Preview {
  VStack {
    TabsView()
      .environmentObject(TabsView.ViewModel.stub(activeTab: 3))
    
    TabsView()
      .environmentObject(TabsView.ViewModel())
      .frame(width: 300)
  }
}


extension TabsView.ViewModel {
  static func stub(activeTab: Int) -> TabsView.ViewModel {
    let viewModel = TabsView.ViewModel()
    viewModel.activeTabId = viewModel.tabs[activeTab].id
    return viewModel
  }
}
