// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tradovate",
    platforms: [.macOS(.v12), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Tradovate",
            targets: ["Tradovate"]
        ),
    ],
    dependencies: [
            .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
            .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
            .package(url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.0.0"),
            .package(url: "https://github.com/TradeWithIt/WebSocket", branch: "main"),
        ],
    targets: [
        .target(
            name: "Tradovate",
            dependencies: [
                .product(name: "WebSocket", package: "WebSocket"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
            ]
        ),
    ]
)
