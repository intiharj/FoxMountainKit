import Foundation
import FirebaseAnalytics

/// Fox Mountain analytics wrapper for Firebase Analytics
/// Provides consistent event tracking across all apps
public enum FMAnalytics {

    // MARK: - Configuration

    /// Initialize Firebase Analytics
    /// Note: Firebase should be configured via GoogleService-Info.plist in each app
    /// This method is called automatically if Firebase is configured correctly
    public static func configure() {
        // Firebase auto-initializes from GoogleService-Info.plist
        // This method is here for explicit initialization if needed
        Analytics.setAnalyticsCollectionEnabled(true)
    }

    /// Disable analytics collection (for user opt-out)
    public static func disable() {
        Analytics.setAnalyticsCollectionEnabled(false)
    }

    /// Enable analytics collection
    public static func enable() {
        Analytics.setAnalyticsCollectionEnabled(true)
    }

    // MARK: - Screen Tracking

    /// Log a screen view event
    /// - Parameters:
    ///   - screenName: Name of the screen
    ///   - screenClass: Optional class name of the screen
    public static func logScreen(_ screenName: String, screenClass: String? = nil) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
    }

    // MARK: - Standard Events

    /// Log app open event
    public static func logAppOpen() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }

    /// Log a button tap event
    /// - Parameter buttonName: Name/identifier of the button
    public static func logButtonTap(_ buttonName: String) {
        Analytics.logEvent("button_tap", parameters: [
            "button_name": buttonName
        ])
    }

    /// Log a feature used event
    /// - Parameters:
    ///   - featureName: Name of the feature
    ///   - parameters: Optional additional parameters
    public static func logFeatureUsed(_ featureName: String, parameters: [String: Any]? = nil) {
        var params: [String: Any] = ["feature_name": featureName]
        if let parameters {
            params.merge(parameters) { _, new in new }
        }
        Analytics.logEvent("feature_used", parameters: params)
    }

    // MARK: - Purchase Events

    /// Log when user views the remove ads prompt
    public static func logRemoveAdsViewed() {
        Analytics.logEvent("remove_ads_viewed", parameters: nil)
    }

    /// Log when user initiates remove ads purchase
    public static func logRemoveAdsTapped() {
        Analytics.logEvent("remove_ads_tapped", parameters: nil)
    }

    /// Log successful ad removal purchase
    /// - Parameter price: Purchase price
    public static func logRemoveAdsPurchased(price: String) {
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterItemName: "remove_ads",
            AnalyticsParameterPrice: price,
            AnalyticsParameterCurrency: "USD"
        ])
    }

    /// Log restore purchases attempt
    public static func logRestorePurchasesTapped() {
        Analytics.logEvent("restore_purchases_tapped", parameters: nil)
    }

    // MARK: - Settings Events

    /// Log a settings change
    /// - Parameters:
    ///   - setting: Name of the setting
    ///   - value: New value (will be converted to string)
    public static func logSettingChanged(_ setting: String, value: Any) {
        Analytics.logEvent("setting_changed", parameters: [
            "setting_name": setting,
            "setting_value": "\(value)"
        ])
    }

    // MARK: - Custom Events

    /// Log a custom event
    /// - Parameters:
    ///   - name: Event name (max 40 characters, alphanumeric + underscores)
    ///   - parameters: Optional parameters dictionary
    public static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }

    // MARK: - User Properties

    /// Set a user property
    /// - Parameters:
    ///   - name: Property name
    ///   - value: Property value
    public static func setUserProperty(_ name: String, value: String?) {
        Analytics.setUserProperty(value, forName: name)
    }

    /// Set the user's ad-free status
    /// - Parameter hasRemovedAds: Whether user has purchased ad removal
    public static func setAdFreeStatus(_ hasRemovedAds: Bool) {
        setUserProperty("ad_free", value: hasRemovedAds ? "true" : "false")
    }
}

// MARK: - SwiftUI View Modifier for Screen Tracking

import SwiftUI

/// Automatically logs screen views when a view appears
public struct AnalyticsScreenModifier: ViewModifier {
    let screenName: String

    public func body(content: Content) -> some View {
        content
            .onAppear {
                FMAnalytics.logScreen(screenName)
            }
    }
}

public extension View {
    /// Track this view as a screen in analytics
    /// - Parameter name: Screen name for analytics
    func analyticsScreen(_ name: String) -> some View {
        modifier(AnalyticsScreenModifier(screenName: name))
    }
}
