import Testing

@testable import DNS

@Test func example() async throws {
  #expect(try await DNS().resolve("example.com") == "example.com resolved")
}
