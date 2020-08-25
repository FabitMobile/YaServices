import Foundation

public typealias ZoomRange = Range<UInt8>

public class MapGeoJsonLayerInfo: Equatable, Hashable {
    public var layerId: String
    public var version: String

    public init(layerId: String, version: String) {
        self.layerId = layerId
        self.version = version
    }

    public static func == (lhs: MapGeoJsonLayerInfo, rhs: MapGeoJsonLayerInfo) -> Bool {
        lhs.layerId == rhs.layerId && lhs.version == rhs.version
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(layerId)
        hasher.combine(version)
    }
}
