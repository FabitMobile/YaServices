import Foundation

public protocol DisplayedTilesQuadKeyStorage {
    func isQuadKeyExist(_ key: TileKey, version: String) -> Bool
    func save(tileKey: TileKey, version: String)

    func lastVersion() -> String?
}
