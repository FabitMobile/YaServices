import CoreLocation
import Foundation
import YandexMapKit

extension YaTilesProvider: YMKResourceUrlProvider {
    public func formatUrl(withResourceId resourceId: String) -> String {
        ""
    }
}

public class YaTilesProvider: NSObject, YMKTileProvider {
    let generator: YaTilesGenerator
    let keyStorage: DisplayedTilesQuadKeyStorage
    var version: String

    private var ymkVersion: YMKVersion {
        YMKVersion(str: version)
    }

    init(version: String,
         generator: YaTilesGenerator,
         keyStorage: DisplayedTilesQuadKeyStorage) {
        self.version = version
        self.generator = generator
        self.keyStorage = keyStorage
    }

    public func load(with tileId: YMKTileId, version: YMKVersion, etag: String) -> YMKRawTile {
        let tileKey = TileKey(ymkTileId: tileId)
        let key = tileKey.quadKey()
        let newEtag = self.version + key

        // etag may be empty, even when the key was marked as presented.
        // in this case we need regen json. It's not an usual case

        if keyStorage.isQuadKeyExist(tileKey, version: self.version), !etag.isEmpty {
            // it's ok, right tile already presented. It's fetched from YaMaps cache
            return YMKRawTile(version: ymkVersion, etag: newEtag, state: .notModified, rawData: Data())
        } else {
            guard let data: Data = try? generator.generateTile(tileId: tileId) else {
                return YMKRawTile(version: ymkVersion, etag: newEtag, state: .error, rawData: Data())
            }
            // mark key as presented
            keyStorage.save(tileKey: tileKey, version: self.version)
            return YMKRawTile(version: ymkVersion, etag: newEtag, state: .ok, rawData: data)
        }
    }
}
