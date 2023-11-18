//
//  ContentView.swift
//  KagiTabs
//
//  Created by ilo on 19/11/2023.
//

import SwiftUI

struct BrowserView: View {
    var body: some View {
        VStack {
          ToolbarView(
            handler: ToolbarView.Handler(
              onBack: {},
              onNewTab: {}))
          
          WebView()
        }
        .padding()
    }
}

#Preview {
    BrowserView()
    .environmentObject(ToolbarView.ViewModel())
}



struct WebView: View {
  var body: some View {
    Text("webview")
  }
}
