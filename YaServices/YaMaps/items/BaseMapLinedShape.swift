import CoreLocation
import UIKit

open class BaseMapLinedShape: BaseMapElement {
    public var coordinates: [CLLocationCoordinate2D]
    public var lineWidth: Double

    public var lineColors: [MapElementState: UIColor]

    public init(identifier: String,
                coordinates: [CLLocationCoordinate2D],
                lineWidth: Double = 1.0,
                lineColors: [MapElementState: UIColor] = [.normal: .blue]) {
        self.coordinates = coordinates
        self.lineWidth = lineWidth
        self.lineColors = lineColors

        super.init(identifier: identifier)
    }

    public convenience init(identifier: String,
                            coordinates: [CLLocationCoordinate2D],
                            lineWidth: Double = 1.0,
                            lineColor: UIColor) {
        self.init(identifier: identifier,
                  coordinates: coordinates,
                  lineWidth: lineWidth,
                  lineColors: [.normal: lineColor])
    }
}
