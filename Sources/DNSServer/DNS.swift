import NIOCore
import NIOPosix

public struct DNS {
  let hostname: String
  let port: Int
  
  public init(hostname: String = "0.0.0.0", port: Int = 53) {
    self.hostname = hostname
    self.port = port
  }
  
  public func run() async throws {
    let server = try await DatagramBootstrap(group: .singletonMultiThreadedEventLoopGroup)
      .bind(host: hostname, port: port)
      .flatMapThrowing { channel in
        return try NIOAsyncChannel(
          wrappingChannelSynchronously: channel,
          configuration: NIOAsyncChannel.Configuration(
            inboundType: AddressedEnvelope<ByteBuffer>.self,
            outboundType: AddressedEnvelope<ByteBuffer>.self
          )
        )
      }
      .get()
    try await server.executeThenClose { inbound, outbound in
      for try await var packet in inbound {
        guard let string = packet.data.readString(length: packet.data.readableBytes) else {
          continue
        }
        
        let response = ByteBuffer(string: String(string.reversed()))
        
        try await outbound.write(AddressedEnvelope(remoteAddress: packet.remoteAddress, data: response))
      }
    }
  }
  
  public func resolve(_ domain: String) async throws -> String {
    return "\(domain) resolved"
  }
}
