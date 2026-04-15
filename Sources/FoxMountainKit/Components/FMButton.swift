import SwiftUI

/// Fox Mountain styled button with multiple variants
public struct FMButton: View {
    public enum Style {
        case primary      // Filled accent background
        case secondary    // Outlined with accent border
        case tertiary     // Text only, no background
        case destructive  // Red/error style
    }

    public enum Size {
        case small   // Compact padding
        case medium  // Default
        case large   // Expanded touch target

        var verticalPadding: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 24
            case .large: return 32
            }
        }

        var font: Font {
            switch self {
            case .small: return FMFonts.footnote
            case .medium: return FMFonts.headline
            case .large: return FMFonts.headline
            }
        }
    }

    private let title: String
    private let icon: String?
    private let style: Style
    private let size: Size
    private let isFullWidth: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        size: Size = .medium,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isFullWidth = fullWidth
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(size.font)
                }
                Text(title)
                    .font(size.font)
            }
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(FMColors.accent, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .tertiary:
            return FMColors.accent
        case .destructive:
            return .white
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return FMColors.accent
        case .secondary, .tertiary:
            return .clear
        case .destructive:
            return FMColors.error
        }
    }
}

// MARK: - Preview

#Preview("Button Styles") {
    VStack(spacing: 16) {
        FMButton("Primary Button", style: .primary) {}
        FMButton("Secondary Button", style: .secondary) {}
        FMButton("Tertiary Button", style: .tertiary) {}
        FMButton("Destructive", style: .destructive) {}
        FMButton("With Icon", icon: "star.fill", style: .primary) {}
        FMButton("Full Width", style: .primary, fullWidth: true) {}
    }
    .padding()
}
