import SwiftUI

/// Fox Mountain onboarding flow
/// A simple, elegant onboarding experience for first-time users
public struct FMOnboardingView: View {

    /// Single onboarding page configuration
    public struct Page: Identifiable {
        public let id = UUID()
        public let icon: String
        public let title: String
        public let description: String
        public let accentColor: Color

        public init(
            icon: String,
            title: String,
            description: String,
            accentColor: Color = FMColors.accent
        ) {
            self.icon = icon
            self.title = title
            self.description = description
            self.accentColor = accentColor
        }
    }

    private let pages: [Page]
    private let onComplete: () -> Void

    @State private var currentPage = 0

    /// Create an onboarding view
    /// - Parameters:
    ///   - pages: Array of pages to show
    ///   - onComplete: Called when user finishes onboarding
    public init(pages: [Page], onComplete: @escaping () -> Void) {
        self.pages = pages
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Bottom controls
            VStack(spacing: 24) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? FMColors.accent : FMColors.border)
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }

                // Continue/Get Started button
                FMButton(
                    currentPage == pages.count - 1 ? "Get Started" : "Continue",
                    style: .primary,
                    fullWidth: true
                ) {
                    FMHaptics.medium()
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        FMPlatformHooks.analytics.logEvent("onboarding_completed", nil)
                        onComplete()
                    }
                }

                // Skip button (not on last page)
                if currentPage < pages.count - 1 {
                    Button {
                        FMPlatformHooks.analytics.logEvent("onboarding_skipped", ["page": currentPage])
                        onComplete()
                    } label: {
                        Text("Skip")
                            .font(FMFonts.body)
                            .foregroundStyle(FMColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FMColors.background)
        .ignoresSafeArea()
    }

    private func pageView(_ page: Page) -> some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: page.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(page.accentColor)
            }

            // Text
            VStack(spacing: 16) {
                Text(page.title)
                    .font(FMFonts.title1)
                    .foregroundStyle(FMColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.description)
                    .font(FMFonts.body)
                    .foregroundStyle(FMColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Onboarding State Management

/// Tracks whether onboarding has been completed
public enum FMOnboardingState {
    private static let completedKey = "fm_onboarding_completed"

    /// Check if onboarding has been completed
    public static var isCompleted: Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }

    /// Mark onboarding as completed
    public static func markCompleted() {
        UserDefaults.standard.set(true, forKey: completedKey)
    }

    /// Reset onboarding state (for testing)
    public static func reset() {
        UserDefaults.standard.removeObject(forKey: completedKey)
    }
}

// MARK: - Preview

#Preview {
    FMOnboardingView(pages: [
        .init(
            icon: "dollarsign.circle",
            title: "Calculate Tips Instantly",
            description: "Enter your bill amount and get the perfect tip calculated in seconds."
        ),
        .init(
            icon: "person.2",
            title: "Split the Bill",
            description: "Dining with friends? Easily split the total among any number of people."
        ),
        .init(
            icon: "hand.tap",
            title: "One-Handed Use",
            description: "Designed for easy one-handed operation. Switch between left and right hand modes."
        )
    ]) {
        print("Onboarding completed!")
    }
}
