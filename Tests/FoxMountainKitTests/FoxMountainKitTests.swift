import XCTest
@testable import FoxMountainKit

final class FoxMountainKitTests: XCTestCase {

    func testVersionExists() {
        XCTAssertFalse(FoxMountainKit.version.isEmpty)
    }

    func testColorsExist() {
        // Verify colors are accessible
        _ = FMColors.accent
        _ = FMColors.background
        _ = FMColors.backgroundSecondary
        _ = FMColors.textPrimary
        _ = FMColors.textSecondary
        _ = FMColors.border
    }

    func testFontsExist() {
        // Verify fonts are accessible
        _ = FMFonts.largeTitle
        _ = FMFonts.title1
        _ = FMFonts.body
        _ = FMFonts.caption1
        _ = FMFonts.numericLarge
    }

    func testHandednessValues() {
        XCTAssertEqual(FMHandedness.left.displayName, "Left")
        XCTAssertEqual(FMHandedness.right.displayName, "Right")
        XCTAssertEqual(FMHandedness.allCases.count, 2)
    }

    func testStorageKeysExist() {
        XCTAssertFalse(FMStorageKeys.onboardingCompleted.isEmpty)
        XCTAssertFalse(FMStorageKeys.handedness.isEmpty)
        XCTAssertFalse(FMStorageKeys.launchCount.isEmpty)
    }
}
