//
//  ContentView.swift
//  Example
//
//  Created by Martin Daum on 26.02.22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var settings: Settings
    
    var body: some View {
        TabView {
            ListView(settings: settings)
            SettingsView(settings: settings)
        }
        .accentColor(Color(uiColor: UIColor.label))
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(settings: Settings())
    }
}
#endif
