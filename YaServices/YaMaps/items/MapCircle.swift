import CoreLocation
import UIKit

open class MapCircle: BaseMapElement {
    public var centrCoordinate: CLLocationCoordinate2D

    public var circleDiameter: Double
    public var colors: [MapElementState: UIColor]

    public init(identifier: String,
                coordinate: CLLocationCoordinate2D,
                cicleDiameter: Double = 4.0,
                colors: [MapElementState: UIColor] = [.normal: .blue]) {
        centrCoordinate = coordinate
        circleDiameter = cicleDiameter
        self.colors = colors

        super.init(identifier: identifier)
    }
}
