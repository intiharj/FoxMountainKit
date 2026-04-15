import SwiftUI

/// Fox Mountain typography system using SF Pro (system font)
public enum FMFonts {

    // MARK: - Display Styles (Large headers)

    /// Large title - 34pt Bold
    public static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)

    /// Title 1 - 28pt Bold
    public static let title1 = Font.system(size: 28, weight: .bold, design: .default)

    /// Title 2 - 22pt Bold
    public static let title2 = Font.system(size: 22, weight: .bold, design: .default)

    /// Title 3 - 20pt Semibold
    public static let title3 = Font.system(size: 20, weight: .semibold, design: .default)

    // MARK: - Body Styles

    /// Headline - 17pt Semibold
    public static let headline = Font.system(size: 17, weight: .semibold, design: .default)

    /// Body - 17pt Regular
    public static let body = Font.system(size: 17, weight: .regular, design: .default)

    /// Callout - 16pt Regular
    public static let callout = Font.system(size: 16, weight: .regular, design: .default)

    /// Subheadline - 15pt Regular
    public static let subheadline = Font.system(size: 15, weight: .regular, design: .default)

    /// Footnote - 13pt Regular
    public static let footnote = Font.system(size: 13, weight: .regular, design: .default)

    /// Caption 1 - 12pt Regular
    public static let caption1 = Font.system(size: 12, weight: .regular, design: .default)

    /// Caption 2 - 11pt Regular
    public static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: - Numeric Styles (for displaying numbers elegantly)

    /// Large numeric display - 48pt Light, rounded design
    public static let numericLarge = Font.system(size: 48, weight: .light, design: .rounded)

    /// Medium numeric display - 32pt Regular, rounded design
    public static let numericMedium = Font.system(size: 32, weight: .regular, design: .rounded)

    /// Small numeric display - 24pt Regular, rounded design
    public static let numericSmall = Font.system(size: 24, weight: .regular, design: .rounded)

    /// Monospaced numeric for aligned columns - 17pt Regular
    public static let numericMono = Font.system(size: 17, weight: .regular, design: .monospaced)
}

// MARK: - View Modifiers

public extension View {
    /// Applies large title style with primary text color
    func fmLargeTitle() -> some View {
        self
            .font(FMFonts.largeTitle)
            .foregroundStyle(FMColors.textPrimary)
    }

    /// Applies title style with primary text color
    func fmTitle() -> some View {
        self
            .font(FMFonts.title2)
            .foregroundStyle(FMColors.textPrimary)
    }

    /// Applies headline style with primary text color
    func fmHeadline() -> some View {
        self
            .font(FMFonts.headline)
            .foregroundStyle(FMColors.textPrimary)
    }

    /// Applies body style with primary text color
    func fmBody() -> some View {
        self
            .font(FMFonts.body)
            .foregroundStyle(FMColors.textPrimary)
    }

    /// Applies caption style with secondary text color
    func fmCaption() -> some View {
        self
            .font(FMFonts.caption1)
            .foregroundStyle(FMColors.textSecondary)
    }

    /// Applies large numeric display style
    func fmNumericLarge() -> some View {
        self
            .font(FMFonts.numericLarge)
            .foregroundStyle(FMColors.textPrimary)
    }

    /// Applies medium numeric display style
    func fmNumericMedium() -> some View {
        self
            .font(FMFonts.numericMedium)
            .foregroundStyle(FMColors.textPrimary)
    }
}
