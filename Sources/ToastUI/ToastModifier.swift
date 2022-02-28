//
//  Toast.swift
//  Ketchup
//
//  Created by Martin Daum on 26.02.22.
//

import SwiftUI

final class DismissWorkItem {
    var workItem: DispatchWorkItem?
    
    func attach(_ item: DispatchWorkItem) {
        workItem = item
    }
    
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}

struct ToastModifier<Item: Identifiable & Equatable, ToastContent: View>: ViewModifier {
    @Binding var item: Item?
    let duration: TimeInterval?
    let alignment: Alignment
    let animation: Animation
    let transition: AnyTransition
    let hideOnTap: Bool
    let toastContent: (Item) -> ToastContent
    let tapClosure: ((Item) -> Void)?
    
    private let workItem: DismissWorkItem = .init()
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        // Toast content
        .overlay (
            VStack {
                if let item = item {
                    toastContent(item)
                        .padding()
                        .zIndex(1000)
                        .animation(.none)
                        .transition(.identity)
                        .onAppear(perform: {
                            if let duration = duration {
                                scheduleDismiss(withDuration: duration)
                            }
                        })
                        .onTapGesture {
                            if let tapClosure = tapClosure {
                                tapClosure(item)
                            } else if hideOnTap {
                                self.item = nil
                            }
                        }
                    }
                }
                .transition(AnyTransition.move(edge: .bottom))
                .animation(animation)
                ,
            alignment: alignment
        )
        .onChange(of: item, perform: { newValue in
            if item != nil, let duration = duration {
                scheduleDismiss(withDuration: duration)
            } else {
                cancelDismiss()
            }
        })
    }
    
    private func scheduleDismiss(withDuration duration: TimeInterval) {
        cancelDismiss()
        
        let work = DispatchWorkItem {
            self.item = nil
        }
        workItem.attach(work)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
    }
    
    private func cancelDismiss() {
        workItem.cancel()
    }
}

extension View {
    public func toast<Item: Identifiable & Equatable, Content: View>(
        item: Binding<Item?>,
        duration: TimeInterval? = nil,
        alignment: Alignment = .bottom,
        animation: Animation = .default,
        transition: AnyTransition = .scale,
        hideOnTap: Bool = true,
        content: @escaping (Item) -> Content,
        tapClosure: ((Item) -> Void)? = nil) -> some View {
            modifier(ToastModifier(item: item, duration: duration, alignment: alignment, animation: animation, transition: transition,  hideOnTap: hideOnTap, toastContent: content, tapClosure: tapClosure))
    }
}
