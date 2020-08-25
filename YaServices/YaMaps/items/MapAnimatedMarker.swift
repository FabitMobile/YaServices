import CoreLocation
import UIKit

public struct MapAnimationFrame {
    public var image: UIImage
    public var duration: TimeInterval

    public init(image: UIImage,
                duration: TimeInterval) {
        self.image = image
        self.duration = duration
    }
}

public struct MapAnimatedMarkerAnimation {
    public let frames: [MapAnimationFrame]
    public let duration: TimeInterval
    public let anchorPoint: CGPoint

    public init(frames: [MapAnimationFrame],
                duration: TimeInterval,
                anchorPoint: CGPoint = .zero) {
        self.frames = frames
        self.duration = duration
        self.anchorPoint = anchorPoint
    }
}

public enum MapAnimatedMarkerState {
    case initial
    case isAnimating
    case didAnimate
}

open class MapAnimatedMarker: BaseMapElement {
    public var coordinate: CLLocationCoordinate2D
    public var animations: [MapElementState: MapAnimatedMarkerAnimation]
    public var delay: Double

    public var animationState: MapAnimatedMarkerState

    public init(identifier: String,
                coordinate: CLLocationCoordinate2D,
                animations: [MapElementState: MapAnimatedMarkerAnimation] = [:]) {
        self.coordinate = coordinate
        self.animations = animations
        delay = 0
        animationState = .initial

        super.init(identifier: identifier)
    }

    public convenience init(identifier: String,
                            coordinate: CLLocationCoordinate2D,
                            animation: MapAnimatedMarkerAnimation) {
        self.init(identifier: identifier,
                  coordinate: coordinate,
                  animations: [.normal: animation])
    }
}
