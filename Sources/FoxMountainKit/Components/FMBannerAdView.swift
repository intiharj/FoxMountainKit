import SwiftUI
import GoogleMobileAds

/// Fox Mountain banner ad view wrapper for AdMob
/// Displays a banner ad at the bottom of the screen
public struct FMBannerAdView: View {
    private let adUnitID: String
    @Binding private var isHidden: Bool

    /// Creates a banner ad view
    /// - Parameters:
    ///   - adUnitID: The AdMob ad unit ID. Use test ID for development: "ca-app-pub-3940256099942544/2934735716"
    ///   - isHidden: Binding to control visibility (hide when user purchases ad removal)
    public init(adUnitID: String, isHidden: Binding<Bool> = .constant(false)) {
        self.adUnitID = adUnitID
        self._isHidden = isHidden
    }

    public var body: some View {
        if !isHidden {
            BannerAdViewRepresentable(adUnitID: adUnitID)
                .frame(height: 50)
                .background(FMColors.backgroundSecondary)
        }
    }
}

// MARK: - UIViewRepresentable

private struct BannerAdViewRepresentable: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.backgroundColor = UIColor(FMColors.backgroundSecondary)

        // Get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootVC
        }

        bannerView.load(GADRequest())
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // No updates needed
    }
}

// MARK: - Test Ad Unit IDs

public extension FMBannerAdView {
    /// Test banner ad unit ID for development
    static let testAdUnitID = "ca-app-pub-3940256099942544/2934735716"
}

// MARK: - Preview

#Preview("Banner Ad") {
    VStack {
        Spacer()
        Text("App Content")
        Spacer()
        FMBannerAdView(adUnitID: FMBannerAdView.testAdUnitID)
    }
    .background(FMColors.background)
}
