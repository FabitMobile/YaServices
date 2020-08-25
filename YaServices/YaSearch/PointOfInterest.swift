import CoreLocation
import Foundation

// sourcery: AutoEquatable
public class PointOfInterest {
    public var title: String
    public var latitude: Double
    public var longitude: Double
    public var address: String?

    public init(title: String, latitude: Double, longitude: Double, adress: String?) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        address = adress
    }

    public var identifier: String {
        "\(title)_\(latitude)_\(longitude)"
    }

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
