//
//  Toast.swift
//  Ketchup
//
//  Created by Martin Daum on 26.02.22.
//

import SwiftUI

final class WindowContainer {
    var window: ToastWindow?
    var completion: (() -> Void)?
    private var workItem: DispatchWorkItem?
    
    func reset() {
        workItem?.cancel()
        workItem = nil
    }
    
    func show(duration: TimeInterval?) {
        guard let window = window else {
            return
        }

        reset()
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.9, options: [.curveEaseInOut]) {
            window.rootViewController?.view.transform = .identity
        } completion: { _ in
            if let duration = duration {
                let workItem = DispatchWorkItem { [weak self] in
                    print("HIDE WORKER")
                    self?.hide()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
                self.workItem = workItem
            }
        }
    }
    
    func hide() {
        guard let window = window else {
            return
        }
    
        reset()
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveLinear]) {
            window.rootViewController?.view.transform = CGAffineTransform(translationX: 0, y: -150)
        } completion: { _ in
            self.completion?()
            self.window = nil
            self.completion = nil
        }
    }
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
}

struct ToastModifier<Item: Identifiable & Equatable, ToastContent: View>: ViewModifier {
    @Binding var item: Item?
    let duration: TimeInterval?
    let hideOnTap: Bool
    let toastContent: (Item) -> ToastContent
    let tapClosure: ((Item) -> Void)?

    private let windowContainer = WindowContainer()
    
    func body(content: Content) -> some View {
        content
            .id(UUID())
            .onChange(of: item) { item in
                if let item = item {
                    let window = ToastWindow(toastView: AnyView(toastContent(item).id(UUID())))
                    windowContainer.window = window
                    windowContainer.completion = {
                        self.item = nil
                    }
                    windowContainer.show(duration: duration)
                } else {
                    windowContainer.hide()
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
            modifier(ToastModifier(item: item, duration: duration, hideOnTap: hideOnTap, toastContent: content, tapClosure: tapClosure))
    }
}
