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
      .onSubmit {
        // TODO
      }
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
