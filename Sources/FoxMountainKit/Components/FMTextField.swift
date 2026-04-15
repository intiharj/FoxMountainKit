import SwiftUI

/// Fox Mountain styled text field with consistent appearance
public struct FMTextField: View {
    public enum Style {
        case filled    // Background color
        case outlined  // Border only
    }

    private let title: String
    private let placeholder: String
    private let icon: String?
    private let style: Style
    private let keyboardType: UIKeyboardType
    @Binding private var text: String
    @FocusState private var isFocused: Bool

    public init(
        _ title: String = "",
        placeholder: String = "",
        text: Binding<String>,
        icon: String? = nil,
        style: Style = .filled,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.style = style
        self.keyboardType = keyboardType
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !title.isEmpty {
                Text(title)
                    .font(FMFonts.caption1)
                    .foregroundStyle(FMColors.textSecondary)
            }

            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isFocused ? FMColors.accent : FMColors.textTertiary)
                }

                TextField(placeholder, text: $text)
                    .font(FMFonts.body)
                    .foregroundStyle(FMColors.textPrimary)
                    .keyboardType(keyboardType)
                    .focused($isFocused)

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(FMColors.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(borderColor, lineWidth: style == .outlined || isFocused ? 1.5 : 0)
            }
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .filled:
            return FMColors.backgroundSecondary
        case .outlined:
            return .clear
        }
    }

    private var borderColor: Color {
        if isFocused {
            return FMColors.accent
        }
        return style == .outlined ? FMColors.border : .clear
    }
}

// MARK: - Numeric Text Field

/// Specialized text field for numeric input
public struct FMNumericField: View {
    private let title: String
    private let placeholder: String
    @Binding private var value: Double
    private let formatter: NumberFormatter

    public init(
        _ title: String = "",
        placeholder: String = "0",
        value: Binding<Double>,
        formatter: NumberFormatter? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._value = value
        self.formatter = formatter ?? {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.minimumFractionDigits = 2
            f.maximumFractionDigits = 2
            return f
        }()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !title.isEmpty {
                Text(title)
                    .font(FMFonts.caption1)
                    .foregroundStyle(FMColors.textSecondary)
            }

            TextField(placeholder, value: $value, formatter: formatter)
                .font(FMFonts.body)
                .foregroundStyle(FMColors.textPrimary)
                .keyboardType(.decimalPad)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(FMColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - Preview

#Preview("Text Fields") {
    ScrollView {
        VStack(spacing: 20) {
            FMTextField(
                "Email",
                placeholder: "Enter your email",
                text: .constant(""),
                icon: "envelope",
                style: .filled
            )

            FMTextField(
                "Search",
                placeholder: "Search...",
                text: .constant("Hello"),
                icon: "magnifyingglass",
                style: .outlined
            )

            FMNumericField(
                "Amount",
                value: .constant(123.45)
            )
        }
        .padding()
    }
    .background(FMColors.background)
}
