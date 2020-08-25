import Foundation
import PromiseKit
import YandexMapKit

class YaTilesGenerator {
    let generator: TileInRegionGenerator
    let projection: YMKProjection

    init(generator: TileInRegionGenerator,
         projection: YMKProjection) {
        self.generator = generator
        self.projection = projection
    }

    func generateTile(tileId: YMKTileId) throws -> Data {
        let a = YMKXYPoint.xYPointWith(x: Double(tileId.x), y: Double(tileId.y))
        let northEast = projection.xyToWorld(with: a, zoom: Int(tileId.z))

        let b = YMKXYPoint.xYPointWith(x: Double(tileId.x + 1), y: Double(tileId.y + 1))
        let southWest = projection.xyToWorld(with: b, zoom: Int(tileId.z))

        let region = MapRegion(minLat: southWest.latitude,
                               maxLat: northEast.latitude,
                               minLon: northEast.longitude,
                               maxLon: southWest.longitude)
        return try generator.tile(in: region).wait()
    }
}
