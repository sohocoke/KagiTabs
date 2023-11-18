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
          ToolbarView(tabs: Tab.stubs)
          
          WebView()
        }
        .padding()
    }
}

#Preview {
    BrowserView()
}



struct WebView: View {
  var body: some View {
    Text("webview")
  }
}
