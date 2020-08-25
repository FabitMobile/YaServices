import CoreLocation
import Foundation

public struct SearchBounds {
    public var southWest: CLLocationCoordinate2D
    public var northEast: CLLocationCoordinate2D

    public init(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D) {
        self.southWest = southWest
        self.northEast = northEast
    }
}
