import Foundation

public struct AnyEncodable: Encodable {
    var _encodeFunc: (Encoder) throws -> Void

    public init(_ encodable: Encodable) {
        func _encode(to encoder: Encoder) throws {
            try encodable.encode(to: encoder)
        }
        _encodeFunc = _encode
    }

    public func encode(to encoder: Encoder) throws {
        try _encodeFunc(encoder)
    }
}
