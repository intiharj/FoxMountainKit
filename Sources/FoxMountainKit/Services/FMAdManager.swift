import SwiftUI
import GoogleMobileAds

/// Fox Mountain ad manager for Google AdMob
/// Coordinates ad display and respects user's ad-free purchase status
@Observable
public final class FMAdManager: NSObject {

    // MARK: - Singleton

    public static let shared = FMAdManager()

    // MARK: - State

    /// Whether ads should be shown (false if user purchased removal)
    public var shouldShowAds: Bool {
        !FMPurchaseManager.shared.hasRemovedAds
    }

    /// Whether an interstitial ad is ready to show
    public private(set) var isInterstitialReady: Bool = false

    /// The loaded interstitial ad
    private var interstitialAd: GADInterstitialAd?

    /// Banner ad unit ID for the current app
    private var bannerAdUnitID: String = FMBannerAdView.testAdUnitID

    /// Interstitial ad unit ID for the current app
    private var interstitialAdUnitID: String = "ca-app-pub-3940256099942544/4411468910"

    // MARK: - Test Ad Unit IDs

    /// Test interstitial ad unit ID for development
    public static let testInterstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"

    // MARK: - Initialization

    private override init() {
        super.init()
    }

    /// Configure the ad manager with your ad unit IDs
    /// Call this in your App's init or on launch
    /// - Parameters:
    ///   - bannerAdUnitID: Your AdMob banner ad unit ID
    ///   - interstitialAdUnitID: Your AdMob interstitial ad unit ID
    public func configure(
        bannerAdUnitID: String,
        interstitialAdUnitID: String
    ) {
        self.bannerAdUnitID = bannerAdUnitID
        self.interstitialAdUnitID = interstitialAdUnitID

        // Initialize Mobile Ads SDK
        GADMobileAds.sharedInstance().start { status in
            print("[FMAdManager] AdMob initialized")
        }

        // Preload an interstitial ad
        loadInterstitialAd()
    }

    /// Configure with test ad unit IDs (for development)
    public func configureForTesting() {
        configure(
            bannerAdUnitID: FMBannerAdView.testAdUnitID,
            interstitialAdUnitID: Self.testInterstitialAdUnitID
        )
    }

    // MARK: - Banner Ads

    /// Get the configured banner ad unit ID
    public func getBannerAdUnitID() -> String {
        bannerAdUnitID
    }

    // MARK: - Interstitial Ads

    /// Load an interstitial ad
    public func loadInterstitialAd() {
        guard shouldShowAds else { return }

        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: interstitialAdUnitID,
            request: request
        ) { [weak self] ad, error in
            guard let self else { return }

            if let error {
                print("[FMAdManager] Failed to load interstitial: \(error.localizedDescription)")
                self.isInterstitialReady = false
                return
            }

            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            self.isInterstitialReady = true
        }
    }

    /// Show an interstitial ad if one is ready
    /// - Returns: Whether the ad was shown
    @discardableResult
    public func showInterstitialAd() -> Bool {
        guard shouldShowAds else { return false }
        guard isInterstitialReady, let interstitialAd else {
            loadInterstitialAd() // Try to load for next time
            return false
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return false
        }

        interstitialAd.present(fromRootViewController: rootVC)
        return true
    }

    /// Show an interstitial ad with a probability (for occasional interruption)
    /// - Parameter probability: Value between 0.0 and 1.0 (e.g., 0.3 for 30% chance)
    /// - Returns: Whether the ad was shown
    @discardableResult
    public func maybeShowInterstitialAd(probability: Double = 0.3) -> Bool {
        guard Double.random(in: 0...1) < probability else { return false }
        return showInterstitialAd()
    }
}

// MARK: - GADFullScreenContentDelegate

extension FMAdManager: GADFullScreenContentDelegate {
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // Reload the interstitial for next time
        isInterstitialReady = false
        loadInterstitialAd()
    }

    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[FMAdManager] Failed to present interstitial: \(error.localizedDescription)")
        isInterstitialReady = false
        loadInterstitialAd()
    }
}

// MARK: - SwiftUI Environment

private struct AdManagerKey: EnvironmentKey {
    static let defaultValue = FMAdManager.shared
}

public extension EnvironmentValues {
    var adManager: FMAdManager {
        get { self[AdManagerKey.self] }
        set { self[AdManagerKey.self] = newValue }
    }
}
