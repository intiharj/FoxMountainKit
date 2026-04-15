import SwiftUI

/// Fox Mountain storage utilities
/// Provides @AppStorage keys and helpers for persistent settings

// MARK: - Storage Keys

/// Standard storage keys used across Fox Mountain apps
public enum FMStorageKeys {
    /// Whether onboarding has been completed
    public static let onboardingCompleted = "fm_onboarding_completed"

    /// Whether ads have been removed (cached from RevenueCat)
    public static let adsRemoved = "fm_ads_removed"

    /// User's preferred handedness (left/right)
    public static let handedness = "fm_handedness"

    /// App launch count
    public static let launchCount = "fm_launch_count"

    /// Last review prompt date
    public static let lastReviewPrompt = "fm_last_review_prompt"

    /// Whether analytics are enabled
    public static let analyticsEnabled = "fm_analytics_enabled"
}

// MARK: - Handedness

/// User's preferred hand for one-handed operation
public enum FMHandedness: String, CaseIterable, Identifiable {
    case left
    case right

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .left: return "Left"
        case .right: return "Right"
        }
    }

    public var alignment: HorizontalAlignment {
        switch self {
        case .left: return .leading
        case .right: return .trailing
        }
    }

    public var edgeAlignment: Alignment {
        switch self {
        case .left: return .leading
        case .right: return .trailing
        }
    }
}

// MARK: - AppStorage Property Wrapper Extensions

/// Provides type-safe @AppStorage for FMHandedness
extension AppStorage where Value == FMHandedness {
    /// Creates an AppStorage for handedness preference
    public init(wrappedValue: FMHandedness = .right, _ key: String = FMStorageKeys.handedness) {
        self.init(wrappedValue: wrappedValue, key)
    }
}

extension FMHandedness: RawRepresentable {
    public typealias RawValue = String
}

// MARK: - Settings Storage Protocol

/// Protocol for app-specific settings storage
public protocol FMSettingsStorage {
    /// Reset all settings to defaults
    func resetToDefaults()
}

// MARK: - Cached Value Helper

/// A property wrapper that caches a value in UserDefaults
@propertyWrapper
public struct FMCached<T> {
    private let key: String
    private let defaultValue: T
    private let storage: UserDefaults

    public init(wrappedValue: T, key: String, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = wrappedValue
        self.storage = storage
    }

    public var wrappedValue: T {
        get {
            storage.object(forKey: key) as? T ?? defaultValue
        }
        set {
            storage.set(newValue, forKey: key)
        }
    }
}

// MARK: - Date Storage Helper

extension UserDefaults {
    /// Get a date value from UserDefaults
    public func date(forKey key: String) -> Date? {
        object(forKey: key) as? Date
    }

    /// Set a date value in UserDefaults
    public func set(_ date: Date?, forKey key: String) {
        set(date, forKey: key)
    }
}
