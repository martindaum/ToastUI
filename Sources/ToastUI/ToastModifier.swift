//
//  Toast.swift
//  Ketchup
//
//  Created by Martin Daum on 26.02.22.
//

import SwiftUI

final class WindowContainer {
    var window: ToastWindow?
}

final class ToastWindow: UIWindow {
    init(toastView: AnyView) {
        if let activeForegroundScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            super.init(windowScene: activeForegroundScene)
        } else if let inactiveForegroundScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundInactive }) as? UIWindowScene {
            super.init(windowScene: inactiveForegroundScene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        windowLevel = .alert
        backgroundColor = .clear
        
        let viewController = UIHostingController(rootView: toastView)
        let rootView = viewController.view ?? UIView()
        rootView.backgroundColor = .clear
        rootView.sizeToFit()
        rootViewController = viewController
        
        let height = rootView.bounds.height
        frame = CGRect(x: 0, y: 0, width: super.bounds.width, height: height + safeAreaInsets.top)
        rootView.transform = CGAffineTransform(translationX: 0, y: -height)
        
        isHidden = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.9, options: [.curveEaseInOut]) {
            self.rootViewController?.view.transform = .identity
        } completion: { _ in
            
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.9, options: [.curveEaseInOut]) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
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

    let windowContainer = WindowContainer()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: item) { item in
                if let item = item {
                    let window = ToastWindow(toastView: AnyView(toastContent(item).id(UUID())))
                    window.show()
                    windowContainer.window = window
                } else {
                    guard let window = windowContainer.window else {
                        return
                    }
                    window.hide()
                    windowContainer.window = nil
                }
            }
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
