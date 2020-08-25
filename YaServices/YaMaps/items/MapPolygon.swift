import CoreLocation
import UIKit

open class MapPolygon: BaseMapLinedShape {
    public var fillColors: [MapElementState: UIColor]

    public init(identifier: String,
                coordinates: [CLLocationCoordinate2D],
                lineWidth: Double = 1.0,
                lineColors: [MapElementState: UIColor] = [.normal: .blue],
                fillColors: [MapElementState: UIColor] = [.normal: .cyan]) {
        self.fillColors = fillColors
        super.init(identifier: identifier,
                   coordinates: coordinates,
                   lineWidth: lineWidth,
                   lineColors: lineColors)
    }

    public convenience init(identifier: String,
                            coordinates: [CLLocationCoordinate2D],
                            lineWidth: Double = 1.0,
                            lineColor: UIColor,
                            fillColor: UIColor) {
        self.init(identifier: identifier,
                  coordinates: coordinates,
                  lineWidth: lineWidth,
                  lineColors: [.normal: lineColor],
                  fillColors: [.normal: fillColor])
    }

    public func makeBoundingRegion() -> MapRegion {
        let latArray = coordinates.map { $0.latitude }
        let lonArray = coordinates.map { $0.longitude }
        return MapRegion(minLat: latArray.min() ?? 0,
                         maxLat: latArray.max() ?? 0,
                         minLon: lonArray.min() ?? 0,
                         maxLon: lonArray.max() ?? 0)
    }
}
