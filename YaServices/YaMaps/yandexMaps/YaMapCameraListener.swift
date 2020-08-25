import Foundation
import YandexMapKit

typealias CameraChangeBlock = (_ region: MapRegion, _ zoom: Double) -> Void

class YaMapCameraListener: NSObject, YMKMapCameraListener {
    var onStart: CameraChangeBlock?
    var onChange: CameraChangeBlock?
    var onEnd: CameraChangeBlock?

    fileprivate var started = false

    func onCameraPositionChanged(with map: YMKMap,
                                 cameraPosition position: YMKCameraPosition,
                                 cameraUpdateSource _: YMKCameraUpdateSource,
                                 finished: Bool) {
        if !finished {
            if !started, let onStart = onStart {
                onStart(mapRegion(map, cameraPosition: position), mapZoom(position))
            } else if let onChange = onChange {
                onChange(mapRegion(map, cameraPosition: position), mapZoom(position))
            }
        } else if let onEnd = onEnd {
            onEnd(mapRegion(map, cameraPosition: position), mapZoom(position))
        }

        started = !finished
    }

    fileprivate func mapRegion(_ map: YMKMap?, cameraPosition: YMKCameraPosition) -> MapRegion {
        guard let map = map else { return MapRegion(minLat: 0, maxLat: 0, minLon: 0, maxLon: 0) }
        return map.visibleRegion(with: cameraPosition).makeMapRegion()
    }

    fileprivate func mapZoom(_ cameraPosition: YMKCameraPosition) -> Double {
        Double(cameraPosition.zoom)
    }
}
