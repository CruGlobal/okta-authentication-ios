// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OktaAuthentication",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "OktaAuthentication",
            targets: ["OktaAuthentication"]),
    ],
    dependencies: [
        .package(url: "https://github.com/okta/okta-oidc-ios.git", .upToNextMinor(from: "3.11.7"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OktaAuthentication",
            dependencies: [
                .product(name: "OktaOidc", package: "okta-oidc-ios")
            ]
        ),
        .testTarget(
            name: "OktaAuthenticationTests",
            dependencies: ["OktaAuthentication"]),
    ]
)
