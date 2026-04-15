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
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "5.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.0.0"),
    ],
    targets: [
        .target(
            name: "FoxMountainKit",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "Sources/FoxMountainKit"
        )
    ]
)
