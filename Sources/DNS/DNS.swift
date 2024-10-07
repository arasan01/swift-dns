public struct DNS {
  public init() {
  }

  public func resolve(_ domain: String) async throws -> String {
    return "\(domain) resolved"
  }
}
