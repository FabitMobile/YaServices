import Foundation

public class YaGeoJsonGenerator: GeoJsonGenerator {
    override func makeFeatureProperties(style: MapGeoJsonStyle) -> AnyEncodable? {
        AnyEncodable(
            [
                "tags": ["\(style.tag)"]
            ]
        )
    }
}
