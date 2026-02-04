// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftVerificarValidationProfiles",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SwiftVerificarValidationProfiles",
            targets: ["SwiftVerificarValidationProfiles"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftVerificarValidationProfiles",
            resources: [
                .copy("Resources/Profiles")
            ]
        ),
        .testTarget(
            name: "SwiftVerificarValidationProfilesTests",
            dependencies: ["SwiftVerificarValidationProfiles"]
        ),
    ]
)
