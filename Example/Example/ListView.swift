//
//  ListView.swift
//  Example
//
//  Created by Martin Daum on 26.02.22.
//

import SwiftUI
import ToastUI

enum ToastType: String, Identifiable {
    case `default`
    case success
    case error
    case warning
    case emoji
    
    var id: String {
        return rawValue
    }
}

struct ListView: View {
    @ObservedObject var settings: Settings
    @State var toastType: ToastType?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        changeToastType(to: .default)
                    } label: {
                        Label("Default", systemImage: "airpods.gen3")
                    }
                    
                    Button {
                        changeToastType(to: .success)
                    } label: {
                        Label("Success", systemImage: "checkmark.circle")
                    }
                    
                    Button {
                        changeToastType(to: .error)
                    } label: {
                        Label("Error", systemImage: "xmark.octagon")
                    }
                    
                    Button {
                        changeToastType(to: .warning)
                    } label: {
                        Label("Warning", systemImage: "exclamationmark.triangle")
                    }
                    
                    Button {
                        changeToastType(to: .emoji)
                    } label: {
                        Label("Emoji", systemImage: "face.smiling")
                    }
                } header: {
                    Text("Default")
                }
            }
            .listRowSeparator(.automatic, edges: .bottom)
            .navigationTitle("ToastUI")
        }
        .toast(item: $toastType, duration: 2) { type -> ToastView in
            switch type {
            case .default:
                return ToastView(title: "Airpods Pro", subtitle: "50%", systemImage: "airpods.gen3")
            case .success:
                return ToastView(title: "Yeah", subtitle: "That worked!", style: .success)
            case .error:
                return ToastView(title: "Oh no", subtitle: "That sucks!", style: .error)
            case .warning:
                return ToastView(title: "Warning!", style: .warning)
            case .emoji:
                return ToastView(title: "Hello World", subtitle: "with Emoji", emoji: "🚀")
            }
        }
        .tabItem {
            Label("Toasts", systemImage: "list.star")
        }
    }
    
    func changeToastType(to newType: ToastType) {
        if toastType == newType {
            toastType = nil
        } else {
            toastType = newType
        }
    }
}

#if DEBUG
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            ListView(settings: Settings())
        }
    }
}
#endif
