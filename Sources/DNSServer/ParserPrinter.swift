import Parsing

public struct ParsingError: Error {
  public init() {}
}

struct Word16Parser: ParserPrinter {
  func parse(_ input: inout ArraySlice<UInt8>) throws -> UInt16 {
    guard input.count >= 2
    else {
      throw ParsingError()
    }
    let output = UInt16(input[input.startIndex]) + UInt16(input[input.startIndex + 1]) << 8
    input.removeFirst(2)
    return output
  }
  
  func print(_ output: UInt16, into input: inout ArraySlice<UInt8>) throws {
    input.prepend(UInt8((output >> 8) & 0xFF))
    input.prepend(UInt8(output & 0xFF))
  }
}

struct DNSHeaderFieldsParser: ParserPrinter {
  func parse(_ input: inout ArraySlice<UInt8>) throws -> DNSHeader.Fields {
    guard input.count >= 2
    else {
      throw ParsingError()
    }
    let byte1 = input[input.startIndex]
    let byte2 = input[input.startIndex + 1]
    input.removeFirst(2)

    return .init(
      qr: Bit(rawValue: byte1 & 0b00000001)!,
      opcode: Opcode(rawValue: (byte1 & 0b00011110) >> 1)!,
      aa: Bit(rawValue: (byte1 & 0b00100000) >> 5)!,
      tc: Bit(rawValue: (byte1 & 0b01000000) >> 6)!,
      rd: Bit(rawValue: (byte1 & 0b10000000) >> 7)!,
      ra: Bit(rawValue: byte2 & 0b00000001)!,
      z: UInt3(rawValue: (byte2 & 0b00001110) >> 1)!,
      rcode: Rcode(rawValue: (byte2 & 0b11110000) >> 4)!
    )
  }
  
  func print(_ output: DNSHeader.Fields, into input: inout ArraySlice<UInt8>) throws {
    input.prepend(
      output.ra.rawValue |
      output.z.rawValue << 1 |
      output.rcode.rawValue << 4
    )
    input.prepend(
      output.qr.rawValue |
      output.opcode.rawValue << 1 |
      output.aa.rawValue << 5 |
      output.tc.rawValue << 6 |
      output.rd.rawValue << 7
    )
  }
}

struct DNSHeaderParser: ParserPrinter {
  
  var body: some ParserPrinter<ArraySlice<UInt8>, DNSHeader> {
    ParsePrint(.memberwise(DNSHeader.init(id:fields:counts:))) {
      Word16Parser()
      
      DNSHeaderFieldsParser()
      
      ParsePrint(.memberwise(DNSHeader.Counts.init(qd:an:ns:ar:))) {
        Word16Parser()
        Word16Parser()
        Word16Parser()
        Word16Parser()
      }
    }
  }
}

struct DNSHeader: Equatable {
  let id: UInt16
  let fields: Fields
  let counts: Counts
  
  struct Fields: Equatable {
    let qr: Bit
    let opcode: Opcode
    let aa: Bit
    let tc: Bit
    let rd: Bit
    let ra: Bit
    let z: UInt3
    let rcode: Rcode
  }
  
  struct Counts: Equatable {
    let qd: UInt16
    let an: UInt16
    let ns: UInt16
    let ar: UInt16
  }
}

extension DNSHeader {
  init(
    id: UInt16,
    qr: Bit,
    opcode: Opcode,
    aa: Bit,
    tc: Bit,
    rd: Bit,
    ra: Bit,
    z: UInt3,
    rcode: Rcode,
    qdcount: UInt16,
    ancount: UInt16,
    nscount: UInt16,
    arcount: UInt16
  ) {
    self.init(
      id: id,
      fields: .init(
        qr: qr,
        opcode: opcode,
        aa: aa,
        tc: tc,
        rd: rd,
        ra: ra,
        z: z,
        rcode: rcode
      ),
      counts: .init(
        qd: qdcount,
        an: ancount,
        ns: nscount,
        ar: arcount
      )
    )
  }
}

enum Bit: Equatable, RawRepresentable {
  case zero, one
  
  init?(rawValue: UInt8) {
    if rawValue == 0 {
      self = .zero
    } else if rawValue == 1 {
      self = .one
    } else {
      return nil
    }
  }
  
  var rawValue: UInt8 {
    switch self {
    case .zero:
      return 0
    case .one:
      return 1
    }
  }
}

struct UInt3: Equatable, RawRepresentable {
  let bit0: Bit
  let bit1: Bit
  let bit2: Bit
  
  init?(rawValue: UInt8) {
    guard
      rawValue & 0b11111000 == 0,
      let bit0 = Bit(rawValue: rawValue & 0b001),
      let bit1 = Bit(rawValue: rawValue & 0b010),
      let bit2 = Bit(rawValue: rawValue & 0b100)
    else { return nil }
    
    self.bit0 = bit0
    self.bit1 = bit1
    self.bit2 = bit2
  }
  
  var rawValue: UInt8 {
    UInt8(
      bit0.rawValue |
      bit1.rawValue << 1 |
      bit2.rawValue << 2
    )
  }
}

struct Rcode: Equatable, RawRepresentable {
  init?(rawValue: UInt8) {
    guard rawValue & 0b1111_0000 == 0 else { return nil }
    self.rawValue = rawValue & 0b0000_1111
  }
  
  let rawValue: UInt8
  
  static let noError = Self(rawValue: 0)!
  static let formatError = Self(rawValue: 1)!
  static let serverFailure = Self(rawValue: 2)!
  static let nameError = Self(rawValue: 3)!
  static let notImplemented = Self(rawValue: 4)!
  static let refused = Self(rawValue: 5)!
}

struct Opcode: Equatable, RawRepresentable {
  init?(rawValue: UInt8) {
    guard rawValue & 0b1111_0000 == 0 else { return nil }
    self.rawValue = rawValue & 0b0000_1111
  }
  
  let rawValue: UInt8
  
  static let standardQuery = Self(rawValue: 0)!
  static let inverseQuery = Self(rawValue: 1)!
  static let status = Self(rawValue: 2)!
}
