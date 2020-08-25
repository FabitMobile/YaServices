import CoreLocation
import Foundation

public class MapGeoJsonObject {
    let coordinates: [CLLocationCoordinate2D]

    init(coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }
}

public class MapGeoJsonLine: MapGeoJsonObject {
    let style: MapGeoJsonStyle

    public init(coordinates: [CLLocationCoordinate2D], style: MapGeoJsonStyle) {
        self.style = style
        super.init(coordinates: coordinates)
    }
}
