import CoreGraphics
import CoreLocation
import Foundation

public protocol MapManagerDelegate: AnyObject {
    func mapManager(_ mapManager: MapManager, didTapMarker marker: MapMarker)
    func mapManager(_ mapManager: MapManager, didTapMap coordinate: CLLocationCoordinate2D)
    func mapManager(_ mapManager: MapManager,
                    didTapShape shape: BaseMapElement,
                    withCoordinate coordinate: CLLocationCoordinate2D)

    func mapManager(_ mapManager: MapManager, didBeginChangingRegion region: MapRegion, atZoom zoom: Double)
    func mapManager(_ mapManager: MapManager, didChangeRegion region: MapRegion, atZoom zoom: Double)
    func mapManager(_ mapManager: MapManager, didEndChangingRegion region: MapRegion, atZoom zoom: Double)
}

public extension MapManagerDelegate {
    func mapManager(_: MapManager, didTapMarker _: MapMarker) {}
    func mapManager(_ mapManager: MapManager, didTapMap coordinate: CLLocationCoordinate2D) {}
    func mapManager(_ mapManager: MapManager,
                    didTapShape shape: BaseMapElement,
                    withCoordinate coordinate: CLLocationCoordinate2D) {}

    func mapManager(_ mapManager: MapManager, didBeginChangingRegion region: MapRegion, atZoom zoom: Double) {}
    func mapManager(_ mapManager: MapManager, didChangeRegion region: MapRegion, atZoom zoom: Double) {}
    func mapManager(_ mapManager: MapManager, didEndChangingRegion region: MapRegion, atZoom zoom: Double) {}
}
