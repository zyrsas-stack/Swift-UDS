//
// Swift-UDS. (C) Dr. Michael 'Mickey' Lauer <mickey@vanille-media.de>
//
import CornucopiaCore
import Foundation

public extension UDS {
    
    enum J1850 {
    }
}

public extension UDS.J1850 {
    
    /// A J1850 ISOTP encoder
    final class Encoder: UDS.BusProtocolEncoder {
        
        public init() { }
        
        /// Encode a byte stream by inserting the appropriate framing control bytes as per ISOTP
        public func encode(_ bytes: [UInt8]) throws -> [UInt8] {
            throw UDS.Error.encoderError(string: "J1850 encoding not yet implemented")
        }
    }
    
    /// A J1850 ISOTP decoder
    final class Decoder: UDS.BusProtocolDecoder {
        
        public init() { }
        
        /// Decode a byte stream consisting on multiple individual concatenated frames by removing the protocol framing bytes as per KWP
        public func decode(_ bytes: [UInt8]) throws -> [UInt8] {
            
            guard bytes.count > 9 else { return bytes.dropLast() }
            return try decodeMultiFrame(payload: bytes)
        }
    }
}

private extension UDS.J1850.Decoder {
    
func decodeMultiFrame(payload bytes: [UInt8]) throws -> [UInt8] {

    var result: [UInt8] = []
    var expectedFrame = 1

    for startIndex in stride(from: 0, to: bytes.count, by: 8) {
        let endIndex = min(startIndex + 8, bytes.count)
        let chunk = Array(bytes[startIndex..<endIndex])

        guard chunk.count >= 7 else {
            continue
        }

        let frame = chunk[2]

        // FIXME: Should we check the checksum and filter invalid frames?
        // let checksum = chunk[7]

        guard frame == expectedFrame else {
            let chunkHex = chunk
                .map { String(format: "0x%02X", $0) }
                .joined(separator: " ")

            throw UDS.Error.decoderError(
                string: "Expected frame \(expectedFrame), but got \(frame) in chunk \(chunkHex)"
            )
        }

        if frame == 1 {
            result.append(chunk[0])
            result.append(chunk[1])
        }

        result += chunk[3..<7]
        expectedFrame += 1
    }

    return result
}
}
