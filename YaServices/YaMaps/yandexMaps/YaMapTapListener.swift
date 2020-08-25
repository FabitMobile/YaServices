import CoreLocation
import Foundation
import YandexMapKit

typealias MapTappedBlock = (_ point: CLLocationCoordinate2D) -> Void

class YaMapTapListener: NSObject, YMKMapInputListener {
    var onTap: MapTappedBlock?

    func onMapTap(with _: YMKMap, point ymkPoint: YMKPoint) {
        if let onTap = onTap {
            onTap(CLLocationCoordinate2D(latitude: ymkPoint.latitude,
                                         longitude: ymkPoint.longitude))
        }
    }

    func onMapLongTap(with _: YMKMap, point _: YMKPoint) {}
}
