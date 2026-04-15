import SwiftUI

/// Fox Mountain branded About screen
/// Displays app info, version, and links to support/privacy
public struct FMAboutView: View {

    /// Configuration for the About screen
    public struct Config {
        public let appName: String
        public let appVersion: String
        public let buildNumber: String
        public let appDescription: String
        public let supportEmail: String
        public let privacyPolicyURL: URL?
        public let termsOfServiceURL: URL?
        public let websiteURL: URL?

        public init(
            appName: String,
            appVersion: String? = nil,
            buildNumber: String? = nil,
            appDescription: String = "",
            supportEmail: String = "support@foxmountain.dev",
            privacyPolicyURL: URL? = nil,
            termsOfServiceURL: URL? = nil,
            websiteURL: URL? = URL(string: "https://foxmountain.dev")
        ) {
            self.appName = appName
            self.appVersion = appVersion ?? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            self.buildNumber = buildNumber ?? Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            self.appDescription = appDescription
            self.supportEmail = supportEmail
            self.privacyPolicyURL = privacyPolicyURL
            self.termsOfServiceURL = termsOfServiceURL
            self.websiteURL = websiteURL
        }
    }

    private let config: Config
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    public init(config: Config) {
        self.config = config
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Logo and branding
                brandingSection

                // App info
                appInfoSection

                // Links
                linksSection

                // Legal
                legalSection

                // Footer
                footerSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(FMColors.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .analyticsScreen("About")
    }

    // MARK: - Sections

    private var brandingSection: some View {
        VStack(spacing: 16) {
            // Fox Mountain logo placeholder
            // In production, replace with actual logo image
            ZStack {
                Circle()
                    .fill(FMColors.backgroundSecondary)
                    .frame(width: 100, height: 100)

                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(FMColors.accent)
            }

            VStack(spacing: 4) {
                Text(config.appName)
                    .font(FMFonts.title1)
                    .foregroundStyle(FMColors.textPrimary)

                Text("by Fox Mountain")
                    .font(FMFonts.subheadline)
                    .foregroundStyle(FMColors.textSecondary)
            }
        }
    }

    private var appInfoSection: some View {
        VStack(spacing: 12) {
            if !config.appDescription.isEmpty {
                Text(config.appDescription)
                    .font(FMFonts.body)
                    .foregroundStyle(FMColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Text("Version \(config.appVersion) (\(config.buildNumber))")
                .font(FMFonts.caption1)
                .foregroundStyle(FMColors.textTertiary)
        }
    }

    private var linksSection: some View {
        VStack(spacing: 0) {
            if let websiteURL = config.websiteURL {
                linkRow(
                    icon: "globe",
                    title: "Visit Website",
                    action: { openURL(websiteURL) }
                )
            }

            linkRow(
                icon: "envelope",
                title: "Contact Support",
                action: { sendSupportEmail() }
            )

            linkRow(
                icon: "star",
                title: "Rate This App",
                action: { requestReview() }
            )
        }
        .background(FMColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var legalSection: some View {
        VStack(spacing: 0) {
            if let privacyURL = config.privacyPolicyURL {
                linkRow(
                    icon: "hand.raised",
                    title: "Privacy Policy",
                    action: { openURL(privacyURL) }
                )
            }

            if let termsURL = config.termsOfServiceURL {
                linkRow(
                    icon: "doc.text",
                    title: "Terms of Service",
                    action: { openURL(termsURL) }
                )
            }
        }
        .background(FMColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("Made with care in the USA")
                .font(FMFonts.caption1)
                .foregroundStyle(FMColors.textTertiary)

            Text("Fox Mountain™")
                .font(FMFonts.caption2)
                .foregroundStyle(FMColors.textTertiary)
        }
        .padding(.top, 16)
    }

    // MARK: - Components

    private func linkRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(FMColors.accent)
                    .frame(width: 24)

                Text(title)
                    .font(FMFonts.body)
                    .foregroundStyle(FMColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(FMColors.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func sendSupportEmail() {
        let subject = "\(config.appName) Support"
        let body = "\n\n---\nApp: \(config.appName)\nVersion: \(config.appVersion) (\(config.buildNumber))\niOS: \(UIDevice.current.systemVersion)\nDevice: \(UIDevice.current.model)"

        if let url = URL(string: "mailto:\(config.supportEmail)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            openURL(url)
        }
    }

    private func requestReview() {
        FMRatePrompt.requestReview()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FMAboutView(config: .init(
            appName: "Tip Calculator",
            appDescription: "Calculate tips quickly and easily, split bills with friends, and always know exactly what to pay.",
            privacyPolicyURL: URL(string: "https://foxmountain.dev/privacy"),
            termsOfServiceURL: URL(string: "https://foxmountain.dev/terms")
        ))
    }
}
