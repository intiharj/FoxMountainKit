import SwiftUI
import UIKit

/// Fox Mountain haptic feedback utilities
/// Provides consistent haptic feedback patterns across all apps
public enum FMHaptics {

    // MARK: - Impact Feedback

    /// Light impact - subtle tap feedback
    public static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Medium impact - standard button tap
    public static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Heavy impact - significant action completed
    public static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Soft impact - gentle feedback
    public static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Rigid impact - firm feedback
    public static func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Selection Feedback

    /// Selection changed - scrolling through options, picker changes
    public static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Notification Feedback

    /// Success notification - task completed successfully
    public static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Warning notification - attention needed
    public static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Error notification - something went wrong
    public static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    // MARK: - Semantic Haptics

    /// Button tap feedback - use for standard button presses
    public static func buttonTap() {
        light()
    }

    /// Toggle feedback - use when toggling switches
    public static func toggle() {
        medium()
    }

    /// Slider tick feedback - use when slider crosses value markers
    public static func sliderTick() {
        selection()
    }

    /// Value change feedback - use when picker value changes
    public static func valueChange() {
        selection()
    }

    /// Action completed - use when significant action finishes
    public static func actionComplete() {
        success()
    }
}

// MARK: - View Modifier

/// Adds haptic feedback to a view on tap
public struct HapticOnTap: ViewModifier {
    let style: HapticStyle

    public enum HapticStyle {
        case light, medium, heavy, selection, success
    }

    public func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded {
                    switch style {
                    case .light: FMHaptics.light()
                    case .medium: FMHaptics.medium()
                    case .heavy: FMHaptics.heavy()
                    case .selection: FMHaptics.selection()
                    case .success: FMHaptics.success()
                    }
                }
            )
    }
}

public extension View {
    /// Adds haptic feedback when the view is tapped
    func hapticOnTap(_ style: HapticOnTap.HapticStyle = .light) -> some View {
        modifier(HapticOnTap(style: style))
    }
}
