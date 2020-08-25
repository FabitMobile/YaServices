import Foundation
import YandexMapKit

extension YMKCameraPosition {
    func changing(target newTarget: YMKPoint) -> YMKCameraPosition {
        let position = YMKCameraPosition(target: newTarget,
                                         zoom: zoom,
                                         azimuth: azimuth,
                                         tilt: tilt)
        return position
    }

    func changing(zoom newZoom: Float) -> YMKCameraPosition {
        let position = YMKCameraPosition(target: target,
                                         zoom: newZoom,
                                         azimuth: azimuth,
                                         tilt: tilt)
        return position
    }
}
