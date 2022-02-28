//
//  ToastView.swift
//  Ketchup
//
//  Created by Martin Daum on 27.02.22.
//

import SwiftUI

public enum HapticFeedbackType {
    case `default`
    case success
    case error
    case warning
}

public struct ToastView: View {
    enum ImageType: Equatable {
        case none
        case system(String)
        case emoji(String)
        case image(UIImage)
    }
    
    public enum Style {
        case success
        case error
        case warning
        
        var imageName: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .error:
                return "xmark.octagon.fill"
            case .warning:
                return "exclamationmark.triangle.fill"
            }
        }
        
        var color: UIColor {
            switch self {
            case .success:
                return .systemGreen
            case .error:
                return .systemRed
            case .warning:
                return .systemYellow
            }
        }
        
        var hapticFeedbackType: HapticFeedbackType {
            switch self {
            case .success:
                return .success
            case .error:
                return .error
            case .warning:
                return .warning
            }
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    private let uuid: UUID
    private let title: String
    private let subtitle: String?
    private let imageType: ImageType
    private let imageColor: UIColor?
    private let hapticFeedbackType: HapticFeedbackType?
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    init(title: String, subtitle: String?, imageType: ImageType, imageColor: UIColor?, hapticFeedbackType: HapticFeedbackType? = nil) {
        self.uuid = UUID()
        self.title = title
        self.subtitle = subtitle
        self.imageType = imageType
        self.imageColor = imageColor
        self.hapticFeedbackType = hapticFeedbackType
    }
    
    public init(title: String, subtitle: String? = nil, image: UIImage? = nil, imageColor: UIColor? = nil, hapticFeedbackType: HapticFeedbackType? = .default) {
        self.init(title: title, subtitle: subtitle, imageType: image.map({ .image($0) }) ?? .none, imageColor: imageColor, hapticFeedbackType: hapticFeedbackType)
    }
    
    public init(title: String, subtitle: String? = nil, systemImage: String, imageColor: UIColor? = nil, hapticFeedbackType: HapticFeedbackType? = .default) {
        self.init(title: title, subtitle: subtitle, imageType: .system(systemImage), imageColor: imageColor, hapticFeedbackType: hapticFeedbackType)
    }
    
    public init(title: String, subtitle: String? = nil, emoji: String, hapticFeedbackType: HapticFeedbackType? = .default) {
        self.init(title: title, subtitle: subtitle, imageType: .emoji(emoji), imageColor: nil, hapticFeedbackType: hapticFeedbackType)
    }
    
    public init(title: String, subtitle: String? = nil, style: Style) {
        self.init(title: title, subtitle: subtitle, systemImage: style.imageName, imageColor: style.color, hapticFeedbackType: style.hapticFeedbackType)
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            Group {
                switch imageType {
                case .none:
                    EmptyView()
                case .system(let string):
                    Image(systemName: string)
                        .id("icon")
                case .emoji(let string):
                    Text(string.prefix(1))
                        .id("icon")
                case .image(let uIImage):
                    Image(uiImage: uIImage)
                        .id("icon")
                }
            }
            .foregroundColor(Color(imageColor ?? UIColor.label))
            
            VStack(alignment: .center, spacing: 0) {
                Text(title)
                    .id("title")
                    .lineLimit(1)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(Color(UIColor.label))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .id("subtitle")
                        .lineLimit(1)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }
            .padding(imageType == .none ? .horizontal : .trailing)
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background(Color(colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground))
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onAppear {
            triggerHapticFeedback()
        }
        .onChange(of: uuid) { _ in
            triggerHapticFeedback()
        }
    }
    
    private func triggerHapticFeedback() {
        guard let hapticFeedbackType = hapticFeedbackType else {
            return
        }
        
        switch hapticFeedbackType {
        case .default:
            selectionFeedbackGenerator.selectionChanged()
        case .success:
            feedbackGenerator.notificationOccurred(.success)
        case .error:
            feedbackGenerator.notificationOccurred(.error)
        case .warning:
            feedbackGenerator.notificationOccurred(.warning)
        }
    }
}

#if DEBUG
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ToastView(title: "Hello World!", subtitle: "Tap to close", emoji: "👍")
            ToastView(title: "Hello World!", subtitle: "Tap to close", systemImage: "airpods.gen3")
            ToastView(title: "Hello World!", subtitle: "Tap to close", style: .success)
            ToastView(title: "Hello World!", subtitle: "Tap to close", style: .error)
            ToastView(title: "Hello World!", subtitle: "Tap to close", style: .warning)
            ToastView(title: "Hello World!", subtitle: "Tap to close")
            ToastView(title: "Hello World!")
        }
        .previewLayout(.fixed(width: 300, height: 600))
        .preferredColorScheme(.light)
    }
}
#endif
