import Foundation

public struct TileKey: Hashable, Codable {
    public var x: UInt
    public var y: UInt
    public var z: UInt

    public func quadKey() -> String {
        var result: String = ""
        for i in (0 ... z).reversed() {
            guard i != 0 else { continue }
            var digit = 0
            let mask = 1 << (i - 1)
            if (x & mask) != 0 {
                digit += 1
            }
            if (y & mask) != 0 {
                digit += 2
            }
            result.append(String(digit))
        }
        return result
    }
}
