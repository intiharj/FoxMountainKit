import SwiftUI
import RevenueCat

/// Fox Mountain purchase manager using RevenueCat
/// Handles the "Remove Ads" in-app purchase across all apps
@Observable
public final class FMPurchaseManager {

    // MARK: - Singleton

    public static let shared = FMPurchaseManager()

    // MARK: - State

    /// Whether ads have been removed (user has purchased)
    public private(set) var hasRemovedAds: Bool = false

    /// Whether a purchase is currently in progress
    public private(set) var isPurchasing: Bool = false

    /// Current offerings from RevenueCat
    public private(set) var offerings: Offerings?

    /// The "Remove Ads" package if available
    public var removeAdsPackage: Package? {
        offerings?.current?.availablePackages.first
    }

    /// Formatted price for the remove ads purchase
    public var removeAdsPrice: String {
        removeAdsPackage?.localizedPriceString ?? "$1.99"
    }

    /// Error message if purchase failed
    public private(set) var errorMessage: String?

    // MARK: - Product IDs

    /// The entitlement ID for ad-free access
    public static let adFreeEntitlementID = "ad_free"

    // MARK: - Initialization

    private init() {}

    /// Configure RevenueCat with your API key
    /// Call this in your App's init or on launch
    /// - Parameter apiKey: Your RevenueCat public API key
    public func configure(apiKey: String) {
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: apiKey)

        // Check initial purchase status
        Task {
            await checkPurchaseStatus()
            await fetchOfferings()
        }
    }

    // MARK: - Purchase Methods

    /// Check if user has the ad-free entitlement
    public func checkPurchaseStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await MainActor.run {
                self.hasRemovedAds = customerInfo.entitlements[Self.adFreeEntitlementID]?.isActive == true
            }
        } catch {
            print("[FMPurchaseManager] Error checking purchase status: \(error)")
        }
    }

    /// Fetch available offerings
    public func fetchOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            await MainActor.run {
                self.offerings = offerings
            }
        } catch {
            print("[FMPurchaseManager] Error fetching offerings: \(error)")
        }
    }

    /// Purchase the "Remove Ads" package
    public func purchaseRemoveAds() async -> Bool {
        guard let package = removeAdsPackage else {
            await MainActor.run {
                self.errorMessage = "No purchase package available"
            }
            return false
        }

        await MainActor.run {
            self.isPurchasing = true
            self.errorMessage = nil
        }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            await MainActor.run {
                self.isPurchasing = false
                self.hasRemovedAds = result.customerInfo.entitlements[Self.adFreeEntitlementID]?.isActive == true
            }

            if hasRemovedAds {
                FMHaptics.success()
            }

            return hasRemovedAds
        } catch let error as ErrorCode {
            await MainActor.run {
                self.isPurchasing = false
                switch error {
                case .purchaseCancelledError:
                    self.errorMessage = nil // User cancelled, not an error
                default:
                    self.errorMessage = "Purchase failed. Please try again."
                }
            }
            return false
        } catch {
            await MainActor.run {
                self.isPurchasing = false
                self.errorMessage = "Purchase failed. Please try again."
            }
            return false
        }
    }

    /// Restore previous purchases
    public func restorePurchases() async -> Bool {
        await MainActor.run {
            self.isPurchasing = true
            self.errorMessage = nil
        }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()

            await MainActor.run {
                self.isPurchasing = false
                self.hasRemovedAds = customerInfo.entitlements[Self.adFreeEntitlementID]?.isActive == true
            }

            if hasRemovedAds {
                FMHaptics.success()
            }

            return hasRemovedAds
        } catch {
            await MainActor.run {
                self.isPurchasing = false
                self.errorMessage = "Restore failed. Please try again."
            }
            return false
        }
    }
}

// MARK: - SwiftUI Environment

private struct PurchaseManagerKey: EnvironmentKey {
    static let defaultValue = FMPurchaseManager.shared
}

public extension EnvironmentValues {
    var purchaseManager: FMPurchaseManager {
        get { self[PurchaseManagerKey.self] }
        set { self[PurchaseManagerKey.self] = newValue }
    }
}

// MARK: - Remove Ads Button View

/// A pre-built button for purchasing ad removal
public struct FMRemoveAdsButton: View {
    @Environment(\.purchaseManager) private var purchaseManager

    public init() {}

    public var body: some View {
        if !purchaseManager.hasRemovedAds {
            Button {
                Task {
                    await purchaseManager.purchaseRemoveAds()
                }
            } label: {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("Remove Ads - \(purchaseManager.removeAdsPrice)")
                }
                .font(FMFonts.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(FMColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(purchaseManager.isPurchasing)
            .opacity(purchaseManager.isPurchasing ? 0.6 : 1)
        }
    }
}

// MARK: - Restore Purchases Button

/// A pre-built button for restoring purchases
public struct FMRestorePurchasesButton: View {
    @Environment(\.purchaseManager) private var purchaseManager

    public init() {}

    public var body: some View {
        Button {
            Task {
                await purchaseManager.restorePurchases()
            }
        } label: {
            Text("Restore Purchases")
                .font(FMFonts.body)
                .foregroundStyle(FMColors.accent)
        }
        .disabled(purchaseManager.isPurchasing)
    }
}
