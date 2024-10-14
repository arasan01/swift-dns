import NIOCore
import NIOPosix
import ServiceLifecycle
import Logging

public struct DNSOverUDP: Service {
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
        return try NIOAsyncChannel<
          AddressedEnvelope<ByteBuffer>,
          AddressedEnvelope<ByteBuffer>
        >(
          wrappingChannelSynchronously: channel
        )
      }
      .get()
    
    try await server.executeThenClose { inbound, outbound in
      for try await var packet in inbound {
        guard let string = packet.data.readString(length: packet.data.readableBytes)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
          continue
        }
        
        let response = ByteBuffer(string: "UDP handler: \(String(string.reversed())) \n")
        
        debugPrint("UDP", packet.remoteAddress)
        try await outbound.write(AddressedEnvelope(remoteAddress: packet.remoteAddress, data: response))
      }
    }
  }
}

public struct DNSOverTCP: Service {
  let hostname: String
  let port: Int
  
  public init(hostname: String = "0.0.0.0", port: Int = 53) {
    self.hostname = hostname
    self.port = port
  }
  
  public func run() async throws {
    let server = try await ServerBootstrap(group: .singletonMultiThreadedEventLoopGroup)
      .bind(host: hostname, port: port) { channel in
        channel.eventLoop.makeCompletedFuture {
          return try NIOAsyncChannel<ByteBuffer, ByteBuffer>(
            wrappingChannelSynchronously: channel
          )
        }
      }
    try await withThrowingDiscardingTaskGroup { group in
      try await server.executeThenClose { clients in
        for try await client in clients {
          group.addTask {
            try await handleClient(client)
          }
        }
      }
    }
  }
  
  func handleClient(_ client: NIOAsyncChannel<ByteBuffer, ByteBuffer>) async throws {
    debugPrint("TCP", client.channel.remoteAddress!)
    do {
      try await client.executeThenClose { connectionChannelInbound, connectionChannelOutbound in
        for try await var inboundData in connectionChannelInbound {
          guard let string = inboundData.readString(length: inboundData.readableBytes)?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
          let response = ByteBuffer(string: "TCP handler: \(String(string.reversed())) \n")
          try await connectionChannelOutbound.write(response)
        }
      }
    } catch {
      debugPrint(error)
    }
  }
}

public struct DNSServer: Service {
  let hostname: String
  let port: Int
  
  public init(hostname: String = "0.0.0.0", port: Int = 53) {
    self.hostname = hostname
    self.port = port
  }
  
  public func run() async throws {
    let udp = DNSOverUDP(hostname: hostname, port: port)
    let tcp = DNSOverTCP(hostname: hostname, port: port)
    let logger = Logger(label: "com.arasan01.dns-service")
    
    let serviceGroup = ServiceGroup(
      services: [udp, tcp],
      gracefulShutdownSignals: [.sigterm, .sigabrt],
      logger: logger
    )
    try await serviceGroup.run()
  }
}
