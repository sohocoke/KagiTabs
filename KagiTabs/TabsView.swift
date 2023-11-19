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

struct TabView: View {
  let tab: Tab
  let isActive: Bool
  
  let onSelect: (Tab) -> Void
  let onClose: (Tab) -> Void
  
  @State var isHovered = false
  @State var isHoveredOnFavicon = false
  
  /// rendered label width, to determine whether to render the 'labelless' version of the tab.
  @State var labelWidth = CGFloat.zero
  
  var body: some View {
    Button {
      onSelect(tab)
    } label: {
      // 'ground truth' rendering of the button, for size computation
      ZStack {
        HStack {
          tab.faviconImage
            .overlay(
              ZStack {
                // show close button when hovered over favicon
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
            // send size pref up to determine whether close button should be rendered on hover
              .background(
                GeometryReader { g in
                  Color.clear
                    .preference(key: LabelWidthPreferenceKey.self, value: g.frame(in: .local).width)
                }
              )
          }
          // REFINE ensure no overflow
        }
        .opacity(isLabelless ? 0 : 1)
        
        // 'labelless' rendering avoids the tab label so the favicon can be centred
        if isLabelless {
          tab.faviconImage
        }
      }
    }
    .buttonStyle(.plain)
    .background(
      TabBackgroundView(isActive: isActive, isHovered: isHovered)
    )
    
    .onPreferenceChange(LabelWidthPreferenceKey.self) { labelWidth in
      self.labelWidth = labelWidth
    }
    .onHover { self.isHovered = $0 }
  }
  
  var isLabelless: Bool {
    !isActive && self.labelWidth < 10 // STUB
  }
}

struct LabelWidthPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero
  
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
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
    
    TabsView()
      .environmentObject(TabsView.ViewModel())
      .frame(width: 100)

  }
}


extension TabsView.ViewModel {
  static func stub(activeTab: Int) -> TabsView.ViewModel {
    let viewModel = TabsView.ViewModel()
    viewModel.activeTabId = viewModel.tabs[activeTab].id
    return viewModel
  }
}
