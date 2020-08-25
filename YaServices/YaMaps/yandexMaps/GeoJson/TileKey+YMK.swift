import YandexMapKit

extension TileKey {
    init(ymkTileId: YMKTileId) {
        x = ymkTileId.x
        y = ymkTileId.y
        z = ymkTileId.z
    }
}
