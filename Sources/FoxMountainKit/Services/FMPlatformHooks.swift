import SwiftUI

/// Lightweight core hooks that keep FoxMountainKit usable without optional SDK modules.
public enum FMPlatformHooks {
    public static var analytics = FMAnalyticsClient()
}

public struct FMAnalyticsClient {
    public var configure: () -> Void = {}
    public var disable: () -> Void = {}
    public var enable: () -> Void = {}
    public var logScreen: (_ screenName: String, _ screenClass: String?) -> Void = { _, _ in }
    public var logEvent: (_ name: String, _ parameters: [String: Any]?) -> Void = { _, _ in }
    public var logSettingChanged: (_ setting: String, _ value: Any) -> Void = { _, _ in }
    public var setUserProperty: (_ name: String, _ value: String?) -> Void = { _, _ in }

    public init() {}
}

public extension View {
    /// Core-safe screen tracking hook. Optional analytics modules can override behavior via FMPlatformHooks.
    func analyticsScreen(_ name: String) -> some View {
        self.onAppear {
            FMPlatformHooks.analytics.logScreen(name, name)
        }
    }
}
