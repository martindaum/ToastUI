//
//  SettingsView.swift
//  Example
//
//  Created by Martin Daum on 28.02.22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings

    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
            }
            .navigationTitle("Settings")
        }
        .tabItem {
            Label("Settings", systemImage: "gear")
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            SettingsView(settings: Settings())
        }
    }
}
#endif
