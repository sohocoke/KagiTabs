import SwiftUI


let addressBarMinWidth = 140.0


struct ToolbarView: View {
  
  var handler: Handler
  
  var body: some View {
    HStack {
      
      Button("Back") {
        handler.onBack()
      }
      
      Spacer()
      
      AddressView()
      
      TabsView()
      
      Spacer()
      
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
      .frame(minWidth: addressBarMinWidth)
//      .onSubmit {
//        // TODO
//      }
    //  wire up submission with sth compatible with macos11
  }
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
