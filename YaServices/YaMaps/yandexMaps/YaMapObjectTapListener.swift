import Foundation
import YandexMapKit

typealias PlacemarkTappedBlock = (_ placemark: YMKPlacemarkMapObject) -> Void
typealias ShapeTappedBlock = (_ shape: YMKMapObject, _ point: YMKPoint) -> Void

class YaMapObjectTapListener: NSObject, YMKMapObjectTapListener {
    var onPlacemarkTap: PlacemarkTappedBlock?
    var onShapeTap: ShapeTappedBlock?

    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        if let onPlacemarkTap = onPlacemarkTap,
            let placemark = mapObject as? YMKPlacemarkMapObject {
            onPlacemarkTap(placemark)
            return true
        } else if let onShapeTap = onShapeTap {
            let object = mapObject
            onShapeTap(object, point)
            return true
        }

        return false
    }
}
