import Foundation
import YandexMapKit

class YaMapLayerData {
    var layerId: String
    var layer: YMKLayer
    var tileProvider: YaTilesProvider

    init(layerId: String, layer: YMKLayer, tileProvider: YaTilesProvider) {
        self.layerId = layerId
        self.layer = layer
        self.tileProvider = tileProvider
    }
}
