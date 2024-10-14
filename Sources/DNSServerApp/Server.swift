import DNSServer

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
@main
struct Application {

  static func main() async throws {
    try await DNSServer(
      hostname: "127.0.0.1",
      port: 8053
    ).run()
  }
}
