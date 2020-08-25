import Foundation
import YandexMapKit

extension YMKVisibleRegion {
    func makeMapRegion() -> MapRegion {
        let points = [
            bottomLeft,
            bottomRight,
            topLeft,
            topRight
        ]

        let mapRegion = MapRegion(minLat: 0, maxLat: 0, minLon: 0, maxLon: 0)

        let latitudes = points.map { $0.latitude }
        mapRegion.minLat = latitudes.min() ?? 0
        mapRegion.maxLat = latitudes.max() ?? 0

        let longitudes = points.map { $0.longitude }
        mapRegion.minLon = longitudes.min() ?? 0
        mapRegion.maxLon = longitudes.max() ?? 0

        return mapRegion
    }
}
