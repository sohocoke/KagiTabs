//
//  KagiTabsApp.swift
//  KagiTabs
//
//  Created by ilo on 19/11/2023.
//

import SwiftUI

@main
struct KagiTabsApp: App {
    var body: some Scene {
        WindowGroup {
            BrowserView()
            .environmentObject(ToolbarView.ViewModel())
        }
    }
}
