import CoreLocation
import UIKit

public struct MapMarkerImage {
    public let image: UIImage?
    public let anchorPoint: CGPoint

    public init(image: UIImage?,
                anchorPoint: CGPoint = .zero) {
        self.image = image
        self.anchorPoint = anchorPoint
    }
}

open class MapMarker: BaseMapElement {
    public var coordinate: CLLocationCoordinate2D

    public var images: [MapElementState: MapMarkerImage]

    public init(identifier: String,
                coordinate: CLLocationCoordinate2D,
                images: [MapElementState: MapMarkerImage] = [:]) {
        self.coordinate = coordinate
        self.images = images

        super.init(identifier: identifier)
    }

    public convenience init(identifier: String,
                            coordinate: CLLocationCoordinate2D,
                            image: MapMarkerImage) {
        self.init(identifier: identifier,
                  coordinate: coordinate,
                  images: [.normal: image])
    }
}
