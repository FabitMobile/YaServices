import Foundation
import YandexMapKit

public struct YaUserLocationSettings {
    let userImage: UIImage?
    let accuracyCircleFillColor: UIColor?
    let shouldRotate: Bool

    public init(userImage: UIImage? = nil,
                accuracyCircleFillColor: UIColor? = nil,
                shouldRotate: Bool = false) {
        self.userImage = userImage
        self.accuracyCircleFillColor = accuracyCircleFillColor
        self.shouldRotate = shouldRotate
    }
}

class YaUserLocationObjectListener: NSObject, YMKUserLocationObjectListener {
    var settings: YaUserLocationSettings?

    func onObjectAdded(with view: YMKUserLocationView) {
        guard let settings = settings else { return }

        if let userImage = settings.userImage {
            if settings.shouldRotate {
                let style = YMKIconStyle(anchor: nil,
                                         rotationType: NSNumber(value: YMKRotationType.rotate.rawValue),
                                         zIndex: nil,
                                         flat: nil,
                                         visible: nil,
                                         scale: nil,
                                         tappableArea: nil)
                view.pin.setIconWith(userImage, style: style)
                view.arrow.setIconWith(userImage, style: style)
            } else {
                view.pin.setIconWith(userImage)
                view.arrow.setIconWith(userImage)
            }
        }
        if let fillColor = settings.accuracyCircleFillColor {
            view.accuracyCircle.fillColor = fillColor
        }
    }

    func onObjectRemoved(with _: YMKUserLocationView) {}

    func onObjectUpdated(with _: YMKUserLocationView, event _: YMKObjectEvent) {}
}
