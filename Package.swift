// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FoxMountainKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FoxMountainKit",
            targets: ["FoxMountainKit"]
        ),
        .library(
            name: "FoxMountainMonetization",
            targets: ["FoxMountainMonetization"]
        ),
        .library(
            name: "FoxMountainAnalytics",
            targets: ["FoxMountainAnalytics"]
        ),
        .library(
            name: "FoxMountainAds",
            targets: ["FoxMountainAds"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "5.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.0.0"),
    ],
    targets: [
        .target(
            name: "FoxMountainKit",
            path: "Sources/FoxMountainKit"
        ),
        .target(
            name: "FoxMountainMonetization",
            dependencies: [
                "FoxMountainKit",
                .product(name: "RevenueCat", package: "purchases-ios"),
            ],
            path: "Sources/FoxMountainMonetization"
        ),
        .target(
            name: "FoxMountainAnalytics",
            dependencies: [
                "FoxMountainKit",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
            ],
            path: "Sources/FoxMountainAnalytics"
        ),
        .target(
            name: "FoxMountainAds",
            dependencies: [
                "FoxMountainKit",
                "FoxMountainMonetization",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "Sources/FoxMountainAds"
        ),
    ]
)
