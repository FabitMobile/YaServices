import CoreLocation
import Foundation

open class GeoJsonGenerator {
    public init() {}

    open func generateGeoJson(from objects: [MapGeoJsonObject]) -> Data {
        var features: [GeoJsonFeature] = []

        let lines = objects.compactMap { $0 as? MapGeoJsonLine }

        for line in lines {
            let feature = makeFeature(style: line.style,
                                      coordinates: line.coordinates)

            features.append(feature)
        }

        let collection = GeoJsonFeatureCollection(features: features)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(collection) else {
            assertionFailure("can not serialize josn")
            return Data()
        }
        return data
    }

    func makeFeature(style: MapGeoJsonStyle,
                     coordinates: [CLLocationCoordinate2D]) -> GeoJsonFeature {
        let coordinates = coordinates.map { [$0.longitude, $0.latitude] }
        let geometry = GeoJsonFeature.Geometry(type: .lineString,
                                               coordinates: coordinates)

        let props = makeFeatureProperties(style: style)

        let feature = GeoJsonFeature(geometry: geometry,
                                     properties: props)

        return feature
    }

    func makeFeatureProperties(style: MapGeoJsonStyle) -> AnyEncodable? {
        nil
    }
}
