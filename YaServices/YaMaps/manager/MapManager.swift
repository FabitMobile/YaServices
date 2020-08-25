import CoreLocation
import UIKit

public typealias MapManagerCompletion = () -> Void

public struct MapError: Error {}
public typealias MapManagerErrorCompletion = (_ error: MapError?) -> Void

public protocol MapManager: AnyObject {
    // MARK: - props

    var delegate: MapManagerDelegate? { get set }
    var mapManagerAnimatedMarkerProcessingDelegate: MapManagerAnimatedMarkerProcessingDelegate? { get set }

    // MARK: - life cicle

    func register(apiKey: String)

    // MARK: - updateMapElements

    func updateMapElements(_ mapElements: [BaseMapElement], _ completion: MapManagerCompletion?)
    func updateMapElements(toAdd mapElementsToAdd: [BaseMapElement],
                           toRemove mapElementsToRemove: [BaseMapElement],
                           toUpdate mapElementsToUpdate: [BaseMapElement],
                           _ completion: MapManagerCompletion?)

    // MARK: - region

    func setCenteringInsets(_ bottomOffset: CGFloat, _ completion: MapManagerCompletion?)

    func centerAtCoordinate(_ coordinate: CLLocationCoordinate2D, _ completion: MapManagerCompletion?)
    func centerAtCoordinate(_ coordinate: CLLocationCoordinate2D, _ zoom: Float, _ completion: MapManagerCompletion?)
    func centerAtMe(_ completion: MapManagerErrorCompletion?)
    func centerAtMe(zoom: Float, _ completion: MapManagerErrorCompletion?)

    func zoomIn(_ completion: MapManagerCompletion?)
    func zoomIn(_ zoom: Float, completion: MapManagerCompletion?)
    func zoomInRegion(_ mapRegion: MapRegion, completion: MapManagerCompletion?)
    func zoomOut(_ completion: MapManagerCompletion?)

    func visibleRegion(changingZoom zoom: Float) -> MapRegion

    // MARK: - selection

    func selectMarker(_ markerIdentifier: String, deselectingCurrent shouldDeselectCurrent: Bool)
    func deselectMarker(_ markerIdentifier: String)
    func deselectAllMarkers()
    func deselectAllMarkers(_ completion: (() -> Void)?)

    // MARK: - map view

    func mapView() -> UIView
    func invalidateMapView()
    func observeMapRegionChange(_ mode: MapRegionObserverMode)
    func mapCoordinateOfScreenPoint(_ screenPoint: CGPoint) -> CLLocationCoordinate2D?

    // MARK: - markers

    func selectedMarker() -> MapMarker?
    func marker(withIdentifier identifier: String) -> MapMarker?

    // MARK: - geojson

    func isCustomTiledLayerDisplayed(layerId: String) -> Bool

    // its like UITableView's reload data
    func invalidateLayer(layerId: String, withVersion version: String)

    func addCustomTiledLayer(version: String,
                             layerId: String,
                             styles: [MapGeoJsonStyle],
                             generator: TileInRegionGenerator,
                             keyStorage: DisplayedTilesQuadKeyStorage)

    func removeCustomLayer(_ layerId: String)

    func worldToXY(withGeoPoint geoPoint: CLLocationCoordinate2D, zoom: Int) -> (x: Double, y: Double)?
    func xyToWorld(x: Double, y: Double, zoom: Int) -> CLLocationCoordinate2D?

    func setStyle(lightness: Double, saturation: Double)
}
