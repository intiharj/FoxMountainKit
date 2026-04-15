import SwiftUI

/// Fox Mountain brand color palette with automatic light/dark mode support
public enum FMColors {

    // MARK: - Brand Colors

    /// Primary accent color - #5A7B9C (blue-gray)
    /// Use for: buttons, icons, highlights, interactive elements
    public static let accent = Color(light: .init(hex: 0x5A7B9C), dark: .init(hex: 0x7A9BBC))

    /// Primary accent as UIColor for UIKit interop
    public static let accentUI = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: 0x7A9BBC)
            : UIColor(hex: 0x5A7B9C)
    }

    // MARK: - Backgrounds

    /// Main background color
    /// Light: #FFFFFF, Dark: #1F2937
    public static let background = Color(light: .init(hex: 0xFFFFFF), dark: .init(hex: 0x1F2937))

    /// Secondary background for cards and elevated surfaces
    /// Light: #F9FAFB (off-white), Dark: #374151
    public static let backgroundSecondary = Color(light: .init(hex: 0xF9FAFB), dark: .init(hex: 0x374151))

    /// Tertiary background for subtle depth
    /// Light: #F3F4F6, Dark: #4B5563
    public static let backgroundTertiary = Color(light: .init(hex: 0xF3F4F6), dark: .init(hex: 0x4B5563))

    // MARK: - Text Colors

    /// Primary text color
    /// Light: #1F2937 (dark gray), Dark: #F9FAFB (off-white)
    public static let textPrimary = Color(light: .init(hex: 0x1F2937), dark: .init(hex: 0xF9FAFB))

    /// Secondary text color for subtitles, captions
    /// Light: #6B7280, Dark: #9CA3AF
    public static let textSecondary = Color(light: .init(hex: 0x6B7280), dark: .init(hex: 0x9CA3AF))

    /// Tertiary text color for placeholder, disabled
    /// Light: #9CA3AF, Dark: #6B7280
    public static let textTertiary = Color(light: .init(hex: 0x9CA3AF), dark: .init(hex: 0x6B7280))

    // MARK: - UI Elements

    /// Border/divider color
    /// Light: #E5E7EB, Dark: #4B5563
    public static let border = Color(light: .init(hex: 0xE5E7EB), dark: .init(hex: 0x4B5563))

    /// Divider color (lighter than border)
    /// Light: #F3F4F6, Dark: #374151
    public static let divider = Color(light: .init(hex: 0xF3F4F6), dark: .init(hex: 0x374151))

    // MARK: - Semantic Colors

    /// Success color
    public static let success = Color(light: .init(hex: 0x10B981), dark: .init(hex: 0x34D399))

    /// Warning color
    public static let warning = Color(light: .init(hex: 0xF59E0B), dark: .init(hex: 0xFBBF24))

    /// Error/destructive color
    public static let error = Color(light: .init(hex: 0xEF4444), dark: .init(hex: 0xF87171))
}

// MARK: - Color Extensions

extension Color {
    /// Creates a color that adapts to light/dark mode
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }

    /// Creates a color from a hex value
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

extension UIColor {
    /// Creates a UIColor from a hex value
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}

// MARK: - View Extension for Easy Access

public extension View {
    /// Applies the Fox Mountain background color
    func fmBackground() -> some View {
        self.background(FMColors.background)
    }

    /// Applies the Fox Mountain accent color as foreground
    func fmAccent() -> some View {
        self.foregroundStyle(FMColors.accent)
    }
}
