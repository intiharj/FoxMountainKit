import SwiftUI

/// Fox Mountain styled card container with consistent styling
public struct FMCard<Content: View>: View {
    public enum Style {
        case elevated   // Shadow + background
        case filled     // Background only, no shadow
        case outlined   // Border only
    }

    private let style: Style
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let content: Content

    public init(
        style: Style = .elevated,
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                if style == .outlined {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(FMColors.border, lineWidth: 1)
                }
            }
            .shadow(
                color: style == .elevated ? Color.black.opacity(0.08) : .clear,
                radius: style == .elevated ? 8 : 0,
                x: 0,
                y: style == .elevated ? 4 : 0
            )
    }

    private var backgroundColor: Color {
        switch style {
        case .elevated, .filled:
            return FMColors.backgroundSecondary
        case .outlined:
            return .clear
        }
    }
}

// MARK: - Convenience Initializers

public extension FMCard where Content == EmptyView {
    /// Creates an empty card (useful for backgrounds)
    init(style: Style = .elevated) {
        self.init(style: style) { EmptyView() }
    }
}

// MARK: - View Extension

public extension View {
    /// Wraps content in an FMCard with elevated style
    func fmCard(
        style: FMCard<Self>.Style = .elevated,
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 16
    ) -> some View {
        FMCard(style: style, padding: padding, cornerRadius: cornerRadius) {
            self
        }
    }
}

// MARK: - Preview

#Preview("Card Styles") {
    ScrollView {
        VStack(spacing: 20) {
            FMCard(style: .elevated) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Elevated Card")
                        .font(FMFonts.headline)
                    Text("This card has a subtle shadow for depth.")
                        .font(FMFonts.body)
                        .foregroundStyle(FMColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            FMCard(style: .filled) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Filled Card")
                        .font(FMFonts.headline)
                    Text("This card has a background but no shadow.")
                        .font(FMFonts.body)
                        .foregroundStyle(FMColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            FMCard(style: .outlined) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Outlined Card")
                        .font(FMFonts.headline)
                    Text("This card has only a border.")
                        .font(FMFonts.body)
                        .foregroundStyle(FMColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
    .background(FMColors.background)
}
