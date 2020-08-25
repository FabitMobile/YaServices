import Foundation

public protocol TilesCache {
    func persist(tile: Data, at key: TileKey, version: String)
    func cachedTile(at key: TileKey, version: String) -> Data?
}
