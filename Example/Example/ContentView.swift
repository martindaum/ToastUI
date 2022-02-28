//
//  ContentView.swift
//  Example
//
//  Created by Martin Daum on 26.02.22.
//

import SwiftUI
import ToastUI

enum ToastType: String, Identifiable {
    case emoji
    case success
    case error
    case warning
    
    var id: String {
        return rawValue
    }
}

struct ContentView: View {
    @State var toastType: ToastType?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        changeToastType(to: .emoji)
                    } label: {
                        Label("Emoji", systemImage: "face.smiling")
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
                }
            }
            .navigationTitle("ToastUI")
        }
        .toast(item: $toastType, duration: 2) { type -> ToastView in
            switch type {
            case .emoji:
                return ToastView(title: "Hello World", subtitle: "with Emoji", emoji: "🚀")
            case .success:
                return ToastView(title: "Yeah", subtitle: "That worked!", style: .success)
            case .error:
                return ToastView(title: "Oh no", subtitle: "That sucks!", style: .error)
            case .warning:
                return ToastView(title: "Warning!", style: .warning)
            }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
