// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-dns",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "DNS",
      targets: ["DNS"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.74.0"),
    .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-atomics.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
    .package(url: "https://github.com/apple/swift-metrics.git", from: "2.5.0"),
    .package(url: "https://github.com/apple/swift-distributed-tracing.git", from: "1.0.1"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "DNS",
      dependencies: [
        .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
        .product(name: "Atomics", package: "swift-atomics"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Metrics", package: "swift-metrics"),
        .product(name: "Tracing", package: "swift-distributed-tracing"),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
        .product(name: "NIOExtras", package: "swift-nio-extras"),
        .product(name: "NIOPosix", package: "swift-nio"),
        .product(name: "NIOTransportServices", package: "swift-nio-transport-services"),
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
      ]
    ),
    .testTarget(
      name: "DNSTests",
      dependencies: ["DNS"]
    ),
  ]
)
