import Testing

@testable import DNSServer

@Suite struct Word16ParserTests {
  @Test func word16_0xAA_invalid() throws {
    let bytes: [UInt8] = [0xAA]
    var slice = bytes[...]
    #expect(throws: ParsingError.self) {
      try Word16Parser().parse(&slice)
    }
  }
  
  @Test func word16_0xAA00() throws {
    let bytes: [UInt8] = [0xAA, 0x00]
    var slice = bytes[...]
    #expect(try Word16Parser().parse(&slice) == 0xAA00)
    #expect(try Word16Parser().print(0xAA00) == bytes[...])
  }
  
  @Test func word16_0x00AA() throws {
    let bytes: [UInt8] = [0x00, 0xAA]
    var slice = bytes[...]
    #expect(try Word16Parser().parse(&slice) == 0x00AA)
    #expect(try Word16Parser().print(0x00AA) == bytes[...])
  }
  
  @Test func word16_0xAA00_oversize() throws {
    let bytes: [UInt8] = [0xAA, 0x00, 0xFF]
    var slice = bytes[...]
    #expect(try Word16Parser().parse(&slice) == 0xAA00)
    #expect(slice == [0xFF])
    #expect(try Word16Parser().print(0xAA00) == bytes[...1])
  }
  
  @Test func word16_0x00AA_oversize() throws {
    let bytes: [UInt8] = [0x00, 0xAA, 0xFF]
    var slice = bytes[...]
    #expect(try Word16Parser().parse(&slice) == 0x00AA)
    #expect(slice == [0xFF])
    #expect(try Word16Parser().print(0x00AA) == bytes[...1])
  }
}

@Suite("DNSHeaderParsePrintTests")
struct DNSHeaderParsePrintTests {
  let header: [UInt8] = [
    0x86, 0x2a,
    0x81, 0x80,
    0x00, 0x01,
    0x00, 0x01,
    0x00, 0x00,
    0x00, 0x00
  ]
  let rest: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
  let headerValue = DNSHeader(
    id: 34_346,
    qr: .one,
    opcode: .standardQuery,
    aa: .zero,
    tc: .zero,
    rd: .one,
    ra: .one,
    z: UInt3(rawValue: 0)!,
    rcode: .noError,
    qdcount: 1,
    ancount: 1,
    nscount: 0,
    arcount: 0
  )
  
  @Test func DNSHeaderParseTest() async throws {
    var slice = (header + rest)[...]
    let output: DNSHeader = try DNSHeaderParser().parse(&slice)
    #expect(output == headerValue)
    #expect(slice == rest[...])
  }
  
  @Test func DNSHeaderPrintTest() async throws {
    let slice: ArraySlice<UInt8> = try DNSHeaderParser().print(headerValue)
    #expect(slice == header[...])
  }
}
