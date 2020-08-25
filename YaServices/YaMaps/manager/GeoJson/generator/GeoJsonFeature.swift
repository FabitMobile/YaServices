import Foundation

/// Common used geojson
struct GeoJsonFeatureCollection: Encodable {
    let type: String = "FeatureCollection"
    let features: [GeoJsonFeature]
}

struct GeoJsonFeature: Encodable {
    enum GeometryType: String, Codable {
        case lineString = "LineString"
    }

    struct Geometry: Codable {
        var type: GeometryType
        var coordinates: [[Double]]
    }

    let type: String = "Feature"
    var geometry: Geometry

    /// User defined properties
    var properties: AnyEncodable?
}
