import CoreGraphics
import Foundation

open class MapRegion: Equatable {
    public var minLat: Double
    public var maxLat: Double

    public var minLon: Double
    public var maxLon: Double

    public init(minLat: Double,
                maxLat: Double,
                minLon: Double,
                maxLon: Double) {
        self.minLat = minLat
        self.maxLat = maxLat

        self.minLon = minLon
        self.maxLon = maxLon
    }

    public func latWidth() -> Double {
        maxLat - minLat
    }

    public func lonWidth() -> Double {
        maxLon - minLon
    }

    public func makeRect() -> CGRect {
        CGRect(x: CGFloat(minLat),
               y: CGFloat(minLon),
               width: CGFloat(latWidth()),
               height: CGFloat(lonWidth()))
    }

    public func increased(byTimes times: Double) -> MapRegion {
        var latDiff2: Double = 0
        var lonDiff2: Double = 0

        do {
            let latWidth = self.latWidth()
            let increasedLatWidth = latWidth * times
            let latDiff = increasedLatWidth - latWidth
            latDiff2 = latDiff / 2

            let lonWidth = self.lonWidth()
            let increasedLonWidth = lonWidth * times
            let lonDiff = increasedLonWidth - lonWidth
            lonDiff2 = lonDiff / 2
        }

        let newRegion = MapRegion(minLat: minLat - latDiff2,
                                  maxLat: maxLat + latDiff2,
                                  minLon: minLon - lonDiff2,
                                  maxLon: maxLon + lonDiff2)
        return newRegion
    }

    public static var zero: MapRegion {
        MapRegion(minLat: 0, maxLat: 0, minLon: 0, maxLon: 0)
    }

    public static func == (lhs: MapRegion, rhs: MapRegion) -> Bool {
        guard lhs.minLat == rhs.minLat else { return false }
        guard lhs.maxLat == rhs.maxLat else { return false }
        guard lhs.minLon == rhs.minLon else { return false }
        guard lhs.maxLon == rhs.maxLon else { return false }
        return true
    }
}
