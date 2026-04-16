import SwiftUI

/// Fox Mountain Settings screen template
/// Provides consistent settings UI with optional upgrade/restore hooks.
public struct FMSettingsView<Content: View>: View {

    public struct PurchaseState {
        public var hasRemovedAds: Bool
        public var isPurchasing: Bool
        public var removeAdsPrice: String

        public init(
            hasRemovedAds: Bool = false,
            isPurchasing: Bool = false,
            removeAdsPrice: String = "$1.99"
        ) {
            self.hasRemovedAds = hasRemovedAds
            self.isPurchasing = isPurchasing
            self.removeAdsPrice = removeAdsPrice
        }
    }

    private let appName: String
    private let showPurchaseSection: Bool
    private let purchaseState: PurchaseState
    private let onPurchase: (() async -> Void)?
    private let onRestore: (() async -> Void)?
    private let content: Content

    /// Create a settings view with custom content sections.
    /// Optional purchase hooks let companion monetization modules wire in RevenueCat later.
    public init(
        appName: String,
        showPurchaseSection: Bool = false,
        purchaseState: PurchaseState = .init(),
        onPurchase: (() async -> Void)? = nil,
        onRestore: (() async -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.appName = appName
        self.showPurchaseSection = showPurchaseSection
        self.purchaseState = purchaseState
        self.onPurchase = onPurchase
        self.onRestore = onRestore
        self.content = content()
    }

    public var body: some View {
        List {
            content

            if showPurchaseSection && !purchaseState.hasRemovedAds {
                purchaseSection
            }

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

    private var purchaseSection: some View {
        Section {
            Button {
                guard let onPurchase else { return }
                FMPlatformHooks.analytics.logEvent("remove_ads_tapped", nil)
                Task { await onPurchase() }
            } label: {
                HStack {
                    Label("Remove Ads", systemImage: "xmark.circle")
                        .foregroundStyle(FMColors.textPrimary)

                    Spacer()

                    if purchaseState.isPurchasing {
                        ProgressView()
                    } else {
                        Text(purchaseState.removeAdsPrice)
                            .foregroundStyle(FMColors.accent)
                    }
                }
            }
            .disabled(purchaseState.isPurchasing || onPurchase == nil)
        } header: {
            Text("Upgrade")
        } footer: {
            Text("Remove all ads from the app with a one-time purchase.")
        }
    }

    private var restoreSection: some View {
        Section {
            Button {
                guard let onRestore else { return }
                FMPlatformHooks.analytics.logEvent("restore_purchases_tapped", nil)
                Task { await onRestore() }
            } label: {
                HStack {
                    Text("Restore Purchases")
                        .foregroundStyle(FMColors.accent)

                    Spacer()

                    if purchaseState.isPurchasing {
                        ProgressView()
                    }
                }
            }
            .disabled(purchaseState.isPurchasing || onRestore == nil)
        } footer: {
            if purchaseState.hasRemovedAds {
                Text("Ads have been removed. Thank you for your support!")
            } else {
                Text("Restore previous purchases if you reinstalled the app.")
            }
        }
    }
}

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
            FMPlatformHooks.analytics.logSettingChanged(title, newValue)
            onChange?(newValue)
        }
    }
}

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
            FMPlatformHooks.analytics.logSettingChanged(title, newValue)
        }
    }
}

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
                    FMPlatformHooks.analytics.logSettingChanged(title, value)
                }
            }
            .tint(FMColors.accent)
        }
    }
}

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
