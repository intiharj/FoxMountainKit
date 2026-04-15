import SwiftUI
import StoreKit

/// Fox Mountain rate prompt utility
/// Handles App Store rating requests at appropriate times
public enum FMRatePrompt {

    // MARK: - Storage Keys

    private static let launchCountKey = "fm_launch_count"
    private static let lastPromptDateKey = "fm_last_prompt_date"
    private static let hasRatedKey = "fm_has_rated"
    private static let significantEventsKey = "fm_significant_events"

    // MARK: - Configuration

    /// Number of launches before first prompt
    public static var launchesBeforePrompt: Int = 5

    /// Number of significant events before prompt
    public static var eventsBeforePrompt: Int = 10

    /// Minimum days between prompts
    public static var daysBetweenPrompts: Int = 60

    // MARK: - Tracking

    /// Call this on each app launch to track usage
    public static func trackLaunch() {
        let count = UserDefaults.standard.integer(forKey: launchCountKey)
        UserDefaults.standard.set(count + 1, forKey: launchCountKey)
    }

    /// Call this when user completes a significant action
    /// (e.g., completes a calculation, saves data, etc.)
    public static func trackSignificantEvent() {
        let count = UserDefaults.standard.integer(forKey: significantEventsKey)
        UserDefaults.standard.set(count + 1, forKey: significantEventsKey)
    }

    /// Get current launch count
    public static var launchCount: Int {
        UserDefaults.standard.integer(forKey: launchCountKey)
    }

    /// Get significant event count
    public static var significantEventCount: Int {
        UserDefaults.standard.integer(forKey: significantEventsKey)
    }

    // MARK: - Prompt Logic

    /// Check if conditions are met and request review if appropriate
    /// Call this at natural break points in your app
    public static func requestReviewIfAppropriate() {
        guard shouldPrompt else { return }
        requestReview()
        recordPrompt()
    }

    /// Force request a review (use sparingly, called from About screen)
    public static func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    /// Check if we should show a prompt
    private static var shouldPrompt: Bool {
        // Don't prompt if user has already rated
        if UserDefaults.standard.bool(forKey: hasRatedKey) {
            return false
        }

        // Check minimum launches
        let launches = launchCount
        if launches < launchesBeforePrompt {
            return false
        }

        // Check significant events
        let events = significantEventCount
        if events < eventsBeforePrompt {
            return false
        }

        // Check days since last prompt
        if let lastPromptDate = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastPromptDate, to: Date()).day ?? 0
            if daysSinceLastPrompt < daysBetweenPrompts {
                return false
            }
        }

        return true
    }

    /// Record that we showed a prompt
    private static func recordPrompt() {
        UserDefaults.standard.set(Date(), forKey: lastPromptDateKey)
    }

    /// Mark that the user has rated the app
    /// Call this if you have a way to detect the user rated
    public static func markAsRated() {
        UserDefaults.standard.set(true, forKey: hasRatedKey)
    }

    /// Reset all tracking data (for testing)
    public static func reset() {
        UserDefaults.standard.removeObject(forKey: launchCountKey)
        UserDefaults.standard.removeObject(forKey: lastPromptDateKey)
        UserDefaults.standard.removeObject(forKey: hasRatedKey)
        UserDefaults.standard.removeObject(forKey: significantEventsKey)
    }
}
