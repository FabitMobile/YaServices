import Foundation

public protocol MapManagerAnimatedMarkerProcessingDelegate: AnyObject {
    func map(shouldShowAnimatedMarker animatedMarker: MapAnimatedMarker) -> Bool
    func map(shouldDeleteAnimatedMarker animatedMarker: MapAnimatedMarker) -> Bool
}
