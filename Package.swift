// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-dns",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .tvOS(.v17),
    .watchOS(.v10),
  ],
  products: [
    .library(
      name: "DNSServer",
      targets: ["DNSServer"]
    ),
    .library(
      name: "DNSCache",
      targets: ["DNSCache"]
    ),
    .library(
      name: "DNSClient",
      targets: ["DNSClient"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.73.0"),
    .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.24.0"),
    .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0"),
    // .package(url: "https://github.com/apple/swift-atomics.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
    .package(url: "https://github.com/apple/swift-metrics.git", from: "2.5.0"),
    .package(url: "https://github.com/apple/swift-distributed-tracing.git", from: "1.0.1"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.20.0"),
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0"),
  ],
  targets: [
    .target(
      name: "DNSServer",
      dependencies: [
        .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
        // .product(name: "Atomics", package: "swift-atomics"),
        .product(name: "Metrics", package: "swift-metrics"),
        .product(name: "Tracing", package: "swift-distributed-tracing"),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
        .product(name: "NIOExtras", package: "swift-nio-extras"),
        .product(name: "NIOPosix", package: "swift-nio"),
        .product(name: "NIOTransportServices", package: "swift-nio-transport-services")
      ]
    ),
    .target(
      name: "DNSCache",
      dependencies: [
        "DNSServer",
        .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
        // .product(name: "Atomics", package: "swift-atomics"),
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
    .target(
      name: "DNSClient",
      dependencies: [
        .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
        // .product(name: "Atomics", package: "swift-atomics"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
        .product(name: "NIOExtras", package: "swift-nio-extras"),
        .product(name: "NIOPosix", package: "swift-nio"),
        .product(name: "NIOTransportServices", package: "swift-nio-transport-services"),
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
      ]
    ),
    .executableTarget(
      name: "DNSServerApp",
      dependencies: ["DNSServer"]
    ),
    .testTarget(
      name: "DNSServerTests",
      dependencies: ["DNSServer"]
    ),
  ]
)
