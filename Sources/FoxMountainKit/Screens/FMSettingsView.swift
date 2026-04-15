import SwiftUI

/// Fox Mountain Settings screen template
/// Provides consistent settings UI with built-in sections for purchases
public struct FMSettingsView<Content: View>: View {

    private let appName: String
    private let showPurchaseSection: Bool
    private let content: Content

    @Environment(\.purchaseManager) private var purchaseManager

    /// Create a settings view with custom content sections
    /// - Parameters:
    ///   - appName: Name of the app (for About link)
    ///   - showPurchaseSection: Whether to show the remove ads/restore purchases section
    ///   - content: Custom settings sections to display
    public init(
        appName: String,
        showPurchaseSection: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.appName = appName
        self.showPurchaseSection = showPurchaseSection
        self.content = content()
    }

    public var body: some View {
        List {
            // Custom content sections
            content

            // Purchase section
            if showPurchaseSection && !purchaseManager.hasRemovedAds {
                purchaseSection
            }

            // Restore purchases (always show)
            if showPurchaseSection {
                restoreSection
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(FMColors.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .analyticsScreen("Settings")
    }

    // MARK: - Sections

    private var purchaseSection: some View {
        Section {
            Button {
                FMAnalytics.logRemoveAdsTapped()
                Task {
                    await purchaseManager.purchaseRemoveAds()
                }
            } label: {
                HStack {
                    Label("Remove Ads", systemImage: "xmark.circle")
                        .foregroundStyle(FMColors.textPrimary)

                    Spacer()

                    if purchaseManager.isPurchasing {
                        ProgressView()
                    } else {
                        Text(purchaseManager.removeAdsPrice)
                            .foregroundStyle(FMColors.accent)
                    }
                }
            }
            .disabled(purchaseManager.isPurchasing)
        } header: {
            Text("Upgrade")
        } footer: {
            Text("Remove all ads from the app with a one-time purchase.")
        }
    }

    private var restoreSection: some View {
        Section {
            Button {
                FMAnalytics.logRestorePurchasesTapped()
                Task {
                    await purchaseManager.restorePurchases()
                }
            } label: {
                HStack {
                    Text("Restore Purchases")
                        .foregroundStyle(FMColors.accent)

                    Spacer()

                    if purchaseManager.isPurchasing {
                        ProgressView()
                    }
                }
            }
            .disabled(purchaseManager.isPurchasing)
        } footer: {
            if purchaseManager.hasRemovedAds {
                Text("Ads have been removed. Thank you for your support!")
            } else {
                Text("Restore previous purchases if you reinstalled the app.")
            }
        }
    }
}

// MARK: - Settings Row Components

/// Standard toggle row for settings
public struct FMSettingsToggle: View {
    let title: String
    let icon: String?
    @Binding var isOn: Bool
    let onChange: ((Bool) -> Void)?

    public init(
        _ title: String,
        icon: String? = nil,
        isOn: Binding<Bool>,
        onChange: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self._isOn = isOn
        self.onChange = onChange
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            if let icon {
                Label(title, systemImage: icon)
            } else {
                Text(title)
            }
        }
        .tint(FMColors.accent)
        .onChange(of: isOn) { _, newValue in
            FMHaptics.toggle()
            FMAnalytics.logSettingChanged(title, value: newValue)
            onChange?(newValue)
        }
    }
}

/// Standard picker row for settings
public struct FMSettingsPicker<T: Hashable>: View {
    let title: String
    let icon: String?
    @Binding var selection: T
    let options: [T]
    let labelForOption: (T) -> String

    public init(
        _ title: String,
        icon: String? = nil,
        selection: Binding<T>,
        options: [T],
        label: @escaping (T) -> String
    ) {
        self.title = title
        self.icon = icon
        self._selection = selection
        self.options = options
        self.labelForOption = label
    }

    public var body: some View {
        Picker(selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(labelForOption(option)).tag(option)
            }
        } label: {
            if let icon {
                Label(title, systemImage: icon)
            } else {
                Text(title)
            }
        }
        .tint(FMColors.accent)
        .onChange(of: selection) { _, newValue in
            FMHaptics.selection()
            FMAnalytics.logSettingChanged(title, value: newValue)
        }
    }
}

/// Standard slider row for settings
public struct FMSettingsSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let valueLabel: (Double) -> String

    public init(
        _ title: String,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double = 1,
        label: @escaping (Double) -> String = { "\(Int($0))" }
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.valueLabel = label
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                Text(valueLabel(value))
                    .foregroundStyle(FMColors.accent)
            }

            Slider(value: $value, in: range, step: step) {
                Text(title)
            } onEditingChanged: { editing in
                if !editing {
                    FMHaptics.selection()
                    FMAnalytics.logSettingChanged(title, value: value)
                }
            }
            .tint(FMColors.accent)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FMSettingsView(appName: "Tip Calculator") {
            Section("Defaults") {
                FMSettingsSlider(
                    "Default Tip",
                    value: .constant(20),
                    in: 1...30,
                    label: { "\(Int($0))%" }
                )

                FMSettingsToggle(
                    "Round Up",
                    icon: "arrow.up.circle",
                    isOn: .constant(true)
                )
            }
        }
    }
}
