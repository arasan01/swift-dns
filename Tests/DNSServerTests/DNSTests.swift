import Testing

@testable import DNSServer

@Test func example() async throws {
  #expect(try await DNS().resolve("example.com") == "example.com resolved")
}
